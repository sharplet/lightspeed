# Define a task to compile a swift executable.

require_relative 'build_product_task'

module Lightspeed
  class ExecutableTask < BuildProductTask

    attr_reader :source_files

    def initialize(name, source_files: FileList.new, module_dependencies: [], config: Lightspeed.configuration)
      fail ArgumentError, "At least one source file required" if source_files.empty?
      @source_files = source_files
      super(name, module_dependencies: module_dependencies, config: config)
    end

    def define
      super.enhance(source_files) { |t|
        swift '-o', t.name, '--', *source_files
      }
    end

    def build_product
      File.join(config.executables_dir, name)
    end

  end
end
