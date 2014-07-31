# Define a task to compile a swift executable.

require_relative 'build_product_task'

module Lightspeed
  class ExecutableTask < BuildProductTask

    attr_reader :source_files, :module_dependencies

    def initialize(name, source_files: FileList.new, module_dependencies: ->{ [] }, config: nil)
      fail ArgumentError, "At least one source file required" if source_files.empty?
      @source_files = source_files
      @module_dependencies = module_dependencies
      super(name, config: config)
    end

    def define
      super.enhance(source_files) { |t|
        linker_opts = module_dependencies.().map {|m| "-l#{m}" }
        swift *linker_opts, '-o', t.name, *source_files
      }
    end

    def build_product
      File.join(config.executables_dir, name)
    end

  end
end
