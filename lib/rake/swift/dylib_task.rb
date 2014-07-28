# Emits a Swift dynamic library by linking its object file dependencies.

require 'rake/tasklib'
require_relative 'object_file_task'
require_relative 'proxy_task'

module Swift

  class DylibTask < Rake::TaskLib

    attr_reader :name, :source_files, :module_name

    def initialize(name, source_files, module_name)
      @name = name
      @source_files = source_files
      @module_name = module_name
    end

    def define
      deps = create_objects
      build_product = create_build_product(deps)
      DylibCreationTask.define_task(name => build_product)
    end

    def create_objects
      source_files.map { |s|
        ObjectFileTask.new(from_source: s, module_name: module_name).define
      }.map(&:name)
    end

    def create_build_product(deps)
      BuildProductTask.new(name).define.enhance(deps) { |t|
        object_files = t.sources.select { |s| s.end_with?('.o') }
        module_name = t.name.pathmap("%n").sub(/^lib/, '')
        swift '-emit-library', '-o', t.name, *object_files, '-module-name', module_name
      }
    end

  end

  class DylibCreationTask < Rake::Task
    include ProxyTask
  end

end
