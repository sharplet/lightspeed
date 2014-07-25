# Emits a Swift dynamic library by linking its object file dependencies.

module Swift
  class DylibTask < Rake::FileTask

    extend FileUtils
    extend Rake::DSL

    def self.define_task(*args, &block)
      task_name, arg_names, deps = Rake.application.resolve_args(args)
      build_product = File.join(Configuration.build_products_dir, task_name)

      build_location = directory(build_product.pathmap("%d")).name
      file_task = file(build_product => [*deps, build_location]) { |t|
        object_files = t.sources - [build_location]
        module_name = t.name.pathmap("%n").sub(/^lib/, '')
        swift '-emit-library', '-o', t.name, *object_files, '-module-name', module_name
      }

      super(task_name, *arg_names).enhance([file_task], &block)
    end

    def self.synthesize_object_file_dependencies(source_files, module_name)
      intermediates_dir = Configuration.module_intermediates_dir(module_name)
      object_files = source_files.pathmap("%{,#{intermediates_dir}/}X.o")
      sources_and_objects = source_files.zip(object_files)

      object_file_tasks = sources_and_objects.map { |src, obj|
        build_location = directory(obj.pathmap("%d"))
        Rake::FileTask.define_task(obj => [src, build_location]) { |t|
          swift t.source, '-emit-object', '-o', t.name, '-module-name', module_name
        }
      }
      object_file_tasks.map(&:name)
    end

  end
end
