require 'rake/tasklib'
require 'json'

require_relative 'framework_structure_task'
require_relative 'output_file_map_task'

module Lightspeed
  class FrameworkTask < Rake::TaskLib

    attr_reader :name, :deps, :basename, :config, :arch

    attr_accessor :source_files

    def initialize(name, deps = [], config: Lightspeed.configuration)
      @basename = name.pathmap("%n")
      @name = basename.ext(".framework")
      @deps = deps
      @config = config
      @arch = "x86_64"
    end

    def define
      fail "#{name}: at least one source file required" if source_files.empty?

      structure_task = FrameworkStructureTask.new("#{name}:structure", framework_path) { |f|
        f.swift_sources = swift_sources
        f.header_files = header_files
      }.define

      object_files, swiftmodule_files = compile_objects

      framework_swiftmodule_files = swiftmodule_files.map { |path|
        framework_path = path.pathmap("%{,#{structure_task.swiftmodules_path}/#{arch}}x")
        file(framework_path => path) do |t|
          cp t.source, t.name
        end
        framework_path
      }

      dynamic_library_path = File.join(structure_task.latest_version_path, basename)
      linker_task = file(dynamic_library_path => [structure_task.latest_version_path, *object_files, *framework_swiftmodule_files]) { |t|
        swift "-emit-library", "-o", t.name, "--", *object_files
      }

      ProxyTask.define_task(name => [structure_task.name, linker_task, *deps])
    end

    def compile_objects
      OutputFileMapTask.new(output_file_map_path, swift_sources, swift_object_files).define
      file(output_file_map_path => [*source_files, target_build_dir])

      swift_object_dirs = FileList[swift_object_files].pathmap("%d").uniq.each { |d| directory(d) }

      if defines_underlying_module?
        underlying_module_path = File.join(target_build_dir, "underlying-module")
        underlying_module_header_dir = File.join(underlying_module_path, basename)
        [underlying_module_path, underlying_module_header_dir].each { |d| directory(d) }

        underlying_module_map = File.join(underlying_module_path, "module.modulemap")
        file(underlying_module_map => [*header_files, underlying_module_path, underlying_module_header_dir]) do |t|
          header_files.each do |header|
            cp header, underlying_module_header_dir
          end
          contents = <<-EOS
module #{basename} {
  umbrella "#{basename}"
  module * { export * }
}
EOS
          File.write(t.name, contents)
        end
      end
      underlying_module_deps = [underlying_module_map].compact

      swiftmodule_path = File.join(target_build_dir, basename.ext('.swiftmodule'))
      swiftmodule_files = [swiftmodule_path, swiftmodule_path.ext('.swiftdoc')]

      swiftc_task = task("#{name}:swift_objects" => [output_file_map_path, *underlying_module_deps, *swift_object_dirs, *swift_sources, *deps]) { |t|
        swift "-c",
          "-module-name", basename,
          "-emit-module", "-emit-module-path", swiftmodule_path,
          *(["-I#{underlying_module_path}", "-import-underlying-module"] if defines_underlying_module?),
          "-output-file-map", output_file_map_path,
          "--", *swift_sources
      }

      swift_source_map = swift_sources.zip(swift_object_files)
      swiftc_task.define_singleton_method(:needed?) do
        swift_source_map.reduce(false) { |needed, (source, object)|
          needed ? true : Rake::Task[source].timestamp > Rake::Task[object].timestamp
        }
      end

      (swift_object_files + swiftmodule_files).each { |f| file(f => swiftc_task) }

      other_sources.zip(other_object_files).map { |source, object|
        file(object => [source, directory(object.pathmap("%d")).name, *deps]) do |t|
          sh *%W[
            xcrun -sdk #{config.sdk} clang -c
            -fmodules -fmodule-implementation-of #{basename}
            -o #{t.name}
            -- #{t.source}
          ]
        end
        object
      }

      [(other_object_files + swift_object_files), swiftmodule_files]
    end

    def defines_underlying_module?
      ! header_files.empty?
    end

    def object_files_for(source_files)
      source_files.map(&method(:object_file_for))
    end

    def object_file_for(source_file, relative_to: target_build_dir)
      source_file.pathmap("%{,#{relative_to}/}X.o")
    end

    ## Path & file attributes

    def framework_path
      File.join(config.build_products_dir, name)
    end

    def output_file_map_path
      File.join(target_build_dir, "output-file-map.json")
    end

    def target_build_dir
      directory(config.target_build_dir(basename)).name
    end

    def source_files
      @source_files ||= FileList["#{basename}/**/*.{h,c,swift}"]
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

    def swift_object_files
      @swift_object_files ||= object_files_for(swift_sources)
    end

    def other_sources
      @other_sources ||= source_files - header_files - swift_sources
    end

    def other_object_files
      @other_object_files ||= object_files_for(other_sources)
    end

  end
end
