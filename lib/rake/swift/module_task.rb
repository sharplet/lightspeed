# A ModuleTask represents two file tasks: a dynamic library and an
# associated .swiftmodule file.

require 'rake'
require 'rake/tasklib'
require_relative 'proxy_task'
require_relative 'dylib_task'

module Swift

  class ModuleTask < Rake::TaskLib

    attr_accessor :module_name, :dylib_name, :swiftmodule_name, :source_files

    def initialize(module_name, source_files)
      @module_name = module_name
      @dylib_name = dylib_for_module(module_name)
      @swiftmodule_name = module_name.ext('.swiftmodule')
      @source_files = source_files
    end

    def define
      define_dylib_task
      define_swiftmodule_task
      define_wrapper_task
    end

    def define_dylib_task
      DylibTask.new(dylib_name, source_files, module_name).define
    end

    def define_swiftmodule_task
      SwiftmoduleTask.new(swiftmodule_name, source_files).define
    end

    def define_wrapper_task
      desc "Build module '#{module_name}'"
      ModuleWrapperTask.define_task(module_name => [dylib_name, swiftmodule_name])
    end

    private

    def dylib_for_module(module_name)
      module_name.sub(/^(?!lib)/, 'lib').ext('.dylib')
    end

  end

  class ModuleWrapperTask < Rake::Task
    include ProxyTask
  end

end
