# Define tasks to build a swift application.

require 'rake/tasklib'
require_relative 'executable_task'

module Lightspeed
  class AppTask < Rake::TaskLib

    attr_accessor :source_files, :config

    attr_reader :name, :module_dependencies

    def initialize(*args, config: Lightspeed.configuration)
      name, _, deps = *Rake.application.resolve_args(args)
      @name = name
      @module_dependencies = deps
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
                                            module_dependencies: module_dependencies,
                                            config: config)
      executable.define.enhance(module_dependencies)
    end

  end
end
