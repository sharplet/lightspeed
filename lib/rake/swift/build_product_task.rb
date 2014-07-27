# Given an existing task, defines a backing file task whose location is
# the task's name only relative to a build products directory defined by
# a configuration object. The build products directory is guaranteed to
# exists when the task runs.

require 'rake/tasklib'
require_relative 'configuration'

module Swift
  class BuildProductTask < Rake::TaskLib
    include Rake::DSL
    include FileUtils

    attr_reader :task, :deps, :config

    alias_method :orig_sources, :deps

    def initialize(task, deps, config: Configuration.instance)
      @task = task
      @deps = deps
      @config = config
    end

    def define(&block)
      task.enhance([file(build_product).tap { |file_task|
        file_task.enhance { |t| yield t, self }
        file_task.enhance(deps)
        file_task.enhance([directory(build_location).name])
      }])
    end

    def build_product
      File.join(config.build_products_dir, task.name)
    end

    def build_location
      build_product.pathmap("%d")
    end

  end
end
