# A ModuleTask represents two file tasks: a dynamic library and an
# associated .swiftmodule file.

require 'rake'
require 'rake/tasklib'
require_relative 'dylib_task'
require_relative 'linkable_node'
require_relative 'proxy_task'

module Lightspeed

  class ModuleTask < LinkableNode
    include Rake::DSL

    attr_accessor :dylib_name, :swiftmodule_name, :source_files

    def initialize(name, deps = [])
      super(name, deps)
      @dylib_name = dylib_for_module(name)
      @swiftmodule_name = name.ext('.swiftmodule')
      @source_files = FileList["#{name}/**/*.swift"]
    end

    def source_files=(*args)
      patterns = args.flatten
      @source_files = FileList[*patterns]
    end

    def define
      module_deps = FutureList.new { modules }
      define_dylib_task(module_deps)
      define_swiftmodule_task(module_deps)
      define_wrapper_task
    end

    def define_dylib_task(module_deps)
      DylibTask.new(dylib_name, source_files, name, module_dependencies: module_deps).define
    end

    def define_swiftmodule_task(module_deps)
      SwiftmoduleTask.new(swiftmodule_name, source_files, module_dependencies: module_deps).define
    end

    def define_wrapper_task
      desc "Build module '#{name}'"
      ProxyTask.define_task(name => [dylib_name, swiftmodule_name])
    end

    private

    def dylib_for_module(module_name)
      module_name.sub(/^(?!lib)/, 'lib').ext('.dylib')
    end

  end

end
