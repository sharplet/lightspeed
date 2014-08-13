require 'rake/tasklib'
require 'json'

require_relative 'compile_utils'
require_relative 'framework_structure_task'
require_relative 'output_file_map_task'
require_relative 'swift_compilation_task'
require_relative 'underlying_module_task'

module Lightspeed
  class FrameworkTask < Rake::TaskLib

    include CompileUtils

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
      file(dynamic_library_path => [structure_task.latest_version_path, *object_files, *framework_swiftmodule_files]) { |t|
        swift "-emit-library", "-o", t.name, "--", *object_files
      }

      proxy_task = ProxyTask.define_task(name => [structure_task.name, dynamic_library_path])

      # Ensure the appropriate subtasks are rebuilt if the framework's
      # dependencies change.
      [name, "#{name}:swift_objects", *other_object_files].each { |t| task(t => deps) }

      proxy_task
    end

    def compile_objects
      # Ensure object dirs exist when compiling
      other_object_dirs.each { |dir| directory(dir) }

      # Build up the underlying module if necessary
      if defines_underlying_module?
        underlying_module = UnderlyingModuleTask.new(basename, underlying_module_path, header_files).define
      end

      compile_swift_sources = SwiftCompilationTask.new(target_build_dir, swift_sources, basename, underlying_module).define

      task(compile_swift_sources.task_name => deps)

      other_sources.zip(other_object_files).map { |source, object|
        object_dir = object.pathmap("%d")
        file(object => [source, object_dir]) do |t|
          sh *%W[
            xcrun -sdk #{config.sdk} clang -c
            -fmodules -fmodule-implementation-of #{basename}
            -o #{t.name}
            -- #{t.source}
          ]
        end
        object
      }

      [compile_swift_sources.object_files + other_object_files, compile_swift_sources.swiftmodule_files]
    end

    def defines_underlying_module?
      ! header_files.empty?
    end

    ## Path & file attributes

    def framework_path
      File.join(config.build_products_dir, name)
    end

    def underlying_module_path
      File.join(target_build_dir, "underlying-module")
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

    def other_sources
      @other_sources ||= source_files - header_files - swift_sources
    end

    def object_files
      @object_files ||= swift_object_files + other_object_files
    end

    def other_object_files
      @other_object_files ||= object_files_for(other_sources, relative_to: target_build_dir)
    end

    def other_object_dirs
      @other_object_dirs ||= directories_containing(other_object_files)
    end

    def object_dirs
      @object_dirs ||= (swift_object_dirs + other_object_dirs).uniq
    end

  end
end
