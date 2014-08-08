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
      }
      structure_task.define

      build_dir = directory(config.target_build_dir(basename)).name
      output_file_map = "#{build_dir}/output-file-map.json"
      sources_to_objects  = swift_sources.reduce({}) { |dict, source|
        dict.merge({ source => source.pathmap("%{,#{build_dir}/}X.o") })
      }
      file(output_file_map => [*swift_sources, build_dir]) do |t|
        dict = sources_to_objects.reduce({}) { |dict, (source, object)|
          dict.merge({ source => { "object" => object } })
        }
        File.write(t.name, dict.to_json + "\n")
      end

      object_files = sources_to_objects.values
      object_dirs = FileList[object_files].pathmap("%d").each { |d| directory(d) }

      swiftc_task = task("#{name}:swift_objects" => [output_file_map, *object_dirs, *swift_sources]) { |t|
        swift "-c",
          "-module-name", basename,
          "-emit-module", "-emit-module-path", "#{structure_task.modules_path}/#{arch}.swiftmodule",
          "-output-file-map", output_file_map,
          "--", *swift_sources
      }

      swiftc_task.define_singleton_method(:needed?) do
        sources_to_objects.reduce(false) { |needed, (source, object)|
          needed ? true : Rake::Task[source].timestamp > Rake::Task[object].timestamp
        }
      end

      object_files.each { |object| file(object => swiftc_task) }

      linker_task = file("#{structure_task.latest_version_path}/#{basename}" => [structure_task.latest_version_path, *object_files]) { |t|
        swift "-emit-library", "-o", t.name, "--", *object_files
      }

      ProxyTask.define_task(name => [structure_task.name, linker_task])
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

  end
end
