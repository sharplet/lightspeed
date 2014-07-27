# Emits a Swift dynamic library by linking its object file dependencies.

require_relative 'proxy_task'

module Swift
  class DylibTask < Rake::Task
    include ProxyTask

    extend FileUtils
    extend Rake::DSL

    def self.define_task(*args, &block)
      task_name, arg_names, deps = Rake.application.resolve_args(args)
      task = super(task_name, *arg_names)
      BuildProductTask.new(task, deps).define { |t, desc|
        object_files = desc.orig_sources
        module_name = t.name.pathmap("%n").sub(/^lib/, '')
        swift '-emit-library', '-o', t.name, *object_files, '-module-name', module_name
      }
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
