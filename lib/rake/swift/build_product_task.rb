# Create a file task with the given name, and define a backing file task
# whose location is the task's name only relative to a build products
# directory defined by a configuration object. The build products
# directory is guaranteed to exists when the task runs.

require 'rake/tasklib'
require_relative 'configuration'

module Swift
  class BuildProductTask < Rake::TaskLib

    attr_reader :name, :config

    def initialize(name, config: Configuration.instance)
      @name = name
      @config = config
    end

    def define(&block)
      dir = directory(build_location)
      file(build_product => dir.name)
    end

    def build_product
      File.join(config.build_products_dir, name)
    end

    def build_location
      build_product.pathmap("%d")
    end

  end
end
