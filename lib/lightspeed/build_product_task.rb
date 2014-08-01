# Create a file task with the given name, and define a backing file task
# whose location is the task's name only relative to a build products
# directory defined by a configuration object. The build products
# directory is guaranteed to exists when the task runs.

require 'rake/tasklib'
require_relative 'configuration'

module Lightspeed

  class BuildProductTask < Rake::TaskLib

    attr_reader :name, :module_dependencies, :config

    def initialize(name, module_dependencies: [], config: Configuration.instance)
      @name = name
      @config = config
      @module_dependencies = module_dependencies
    end

    def define
      dir = directory(build_location)
      compile = file(build_product => dir.name)
      compile.prerequisite_modules = module_dependencies
      compile
    end

    def build_product
      File.join(config.build_products_dir, name)
    end

    def build_location
      build_product.pathmap("%d")
    end

    private

    def file(*args, &block)
      BuildProductCompilationTask.define_task(*args, &block)
    end

  end

  class BuildProductCompilationTask < Rake::FileTask
    attr_accessor :prerequisite_modules
    def invoke_with_call_chain(*args)
      enhance(prerequisite_modules || [])
      super(*args)
    end
  end

end
