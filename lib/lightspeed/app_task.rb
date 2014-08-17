# Define tasks to build a swift application.

require 'rake/tasklib'

module Lightspeed
  class AppTask < Rake::TaskLib

    attr_accessor :name, :deps, :source_files, :config

    def initialize(name, deps = [], config: Lightspeed.configuration)
      @name = name
      @deps = deps
      @config = config
    end

    def source_files
      @source_files ||= FileList.new
    end

    def source_files=(*args)
      patterns = args.flatten
      @source_files = FileList.relative_to(config.base_dir, *patterns)
    end

    def define
      build_dir = directory(config.executables_dir).name
      build_product = File.join(build_dir, name)
      file(build_product => [*deps, *source_files, build_dir]) do |t|
        swift "-o", t.name, "--", *source_files
      end
      ProxyTask.define_task(name => build_product)
    end

  end
end
