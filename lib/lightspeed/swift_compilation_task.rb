require 'rake'
require 'rake/tasklib'

require_relative 'compile_utils'
require_relative 'underlying_module_task'

module Lightspeed
  class SwiftCompilationTask < Rake::TaskLib

    include CompileUtils

    attr_reader :build_dir, :source_files, :module_name, :underlying_module

    def initialize(build_dir, source_files, module_name, underlying_module = nil)
      @build_dir = build_dir
      @source_files = source_files
      @module_name = module_name
      @underlying_module = underlying_module
    end

    def define
      object_dirs.each { |dir| directory(dir) }

      # Generate an output file map for swift objects
      OutputFileMapTask.new(output_file_map_path, source_files, object_files).define
      file(output_file_map_path => [*source_files, build_dir])

      swiftc_task = task(task_name => [output_file_map_path, *object_dirs, *source_files]) { |t|
        swift "-c",
          "-module-name", module_name,
          "-emit-module", "-emit-module-path", swiftmodule_path,
          *(["-I#{underlying_module.path}", "-import-underlying-module"] if underlying_module),
          "-output-file-map", output_file_map_path,
          "--", *source_files
      }

      if underlying_module
        swiftc_task.enhance([underlying_module.proxy])
      end

      source_map = source_files.zip(object_files)
      swiftc_task.define_singleton_method(:needed?) do
        source_map.reduce(false) { |needed, (source, object)|
          needed ? true : Rake::Task[source].timestamp > Rake::Task[object].timestamp
        }
      end

      (object_files + swiftmodule_files).each { |f| file(f => swiftc_task) }

      self
    end

    def task_name
      "#{module_name}:compile_swift_sources"
    end

    def object_files
      @swift_object_files ||= object_files_for(source_files, relative_to: build_dir)
    end

    def object_dirs
      @swift_object_dirs ||= directories_containing(object_files)
    end

    def swiftmodule_path
      @swiftmodule_path ||= File.join(build_dir, module_name.ext('.swiftmodule'))
    end

    def swiftdoc_path
      @swiftdoc_path ||= swiftmodule_path.ext('.swiftdoc')
    end

    def swiftmodule_files
      @swiftmodule_files ||= [swiftmodule_path, swiftdoc_path]
    end

    def output_file_map_path
      @output_file_map_path ||= File.join(build_dir, "output-file-map.json")
    end

  end

end
