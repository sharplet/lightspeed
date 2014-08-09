require 'rake/tasklib'
require 'json'

require_relative 'framework_structure_task'

module Lightspeed
  class FrameworkTask < Rake::TaskLib

    attr_reader :name, :basename, :config, :arch

    attr_accessor :source_files

    def initialize(name, config: Lightspeed.configuration)
      @basename = name.pathmap("%n")
      @name = basename.ext(".framework")
      @config = config
      @arch = "x86_64"
    end

    def define
      structure_task = FrameworkStructureTask.new("#{name}:structure", framework_path) { |f|
        f.swift_sources = swift_sources
        f.header_files = header_files
      }.define

      build_dir = directory(config.target_build_dir(basename)).name
      swiftmodule_path = File.join(structure_task.swiftmodules_path, "#{arch}.swiftmodule")
      object_files = compile_objects(build_dir, swiftmodule_path)

      dynamic_library_path = File.join(structure_task.latest_version_path, basename)
      linker_task = file(dynamic_library_path => [structure_task.latest_version_path, *object_files]) { |t|
        swift "-emit-library", "-o", t.name, "--", *object_files
      }

      ProxyTask.define_task(name => [structure_task.name, linker_task])
    end

    def compile_objects(build_dir, swiftmodule_path)
      output_file_map = File.join(build_dir, "output-file-map.json")
      object_map = (swift_sources + other_sources).reduce({}) { |dict, source|
        dict.merge({ source => source.pathmap("%{,#{build_dir}/}X.o") })
      }
      swift_object_map, other_object_map = object_map.partition { |source, object| File.extname(source) == ".swift" }

      file(output_file_map => [*swift_sources, build_dir]) do |t|
        dict = swift_object_map.reduce({}) { |dict, (source, object)|
          dict.merge({ source => { "object" => object } })
        }
        File.write(t.name, dict.to_json + "\n")
      end

      swift_object_files = swift_object_map.map(&:last)
      swift_object_dirs = FileList[swift_object_files].pathmap("%d").uniq.each { |d| directory(d) }

      swiftc_task = task("#{name}:swift_objects" => [output_file_map, *swift_object_dirs, *swift_sources]) { |t|
        swift "-c",
          "-module-name", basename,
          "-emit-module", "-emit-module-path", swiftmodule_path,
          "-output-file-map", output_file_map,
          "--", *swift_sources
      }

      swiftc_task.define_singleton_method(:needed?) do
        swift_object_map.reduce(false) { |needed, (source, object)|
          needed ? true : Rake::Task[source].timestamp > Rake::Task[object].timestamp
        }
      end

      swift_object_files.each { |object| file(object => swiftc_task) }

      other_object_files = other_object_map.map { |source, object|
        file(object => [source, directory(object.pathmap("%d")).name]) do |t|
          sh *%W[
            xcrun -sdk macosx clang -c
            -fmodules -fmodule-implementation-of #{basename}
            -o #{t.name}
            -- #{t.source}
          ]
        end
        object
      }

      other_object_files + swift_object_files
    end

    def framework_path
      File.join(config.build_products_dir, name)
    end

    def source_files
      @source_files ||= FileList.new
    end

    def source_files=(*args)
      @source_files = FileList[*args.flatten]
    end

    def header_files
      @header_files ||= source_files.select { |f| File.extname(f) == ".h" }
    end

    def swift_sources
      @swift_sources ||= source_files.select { |f| File.extname(f) == ".swift" }
    end

    def other_sources
      @other_sources ||= source_files - header_files - swift_sources
    end

  end
end
