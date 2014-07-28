# Emits a Swift dynamic library by linking its object file dependencies.

require_relative 'object_file_task'
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
      source_files.map { |s|
        ObjectFileTask.new(s, module_name: module_name).define
      }.map(&:name)
    end

  end
end
