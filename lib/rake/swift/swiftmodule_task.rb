# Compiles a .swiftmodule file from Swift source file dependencies.

require 'rake/tasklib'

module Swift

  class SwiftmoduleTask < Rake::TaskLib

    attr_reader :name, :sources, :module_name

    def initialize(name, sources, module_name: nil)
      @name = name
      @sources = sources
      @module_name = module_name || name.ext
    end

    def define
      build_product = BuildProductTask.new(name).define.enhance(sources) { |t|
        swift '-emit-module', '-o', t.name, '-module-name', module_name, *sources
      }
      SwiftmoduleCreationTask.define_task(name => build_product)
    end

  end

  class SwiftmoduleCreationTask < Rake::Task
    include ProxyTask
  end

end
