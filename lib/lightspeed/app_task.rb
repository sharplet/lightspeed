# Define tasks to build a swift application.

require 'rake/tasklib'
require_relative 'executable_task'
require_relative 'future_list'
require_relative 'linkable_node'

module Lightspeed
  class AppTask < LinkableNode
    include Rake::DSL

    attr_accessor :source_files, :config

    alias_method :module_dependencies, :children

    def initialize(name, deps = [], config: Lightspeed.configuration)
      super(name, deps)
      @config = config
    end

    def source_files
      @source_files ||= FileList.new
    end

    def source_files=(*args)
      patterns = args.flatten
      @source_files = FileList[*patterns]
    end

    def define
      build_product = executable_task

      desc "Build application '#{name}'"
      ProxyTask.define_task(name => build_product)
    end

    def executable_task
      executable = ExecutableTask.new(name, source_files: source_files,
                                            module_dependencies: FutureList.new { modules },
                                            config: config)
      executable.define.enhance(module_dependencies)
    end

  end
end
