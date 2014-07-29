# Emits a Swift dynamic library by linking its object file dependencies.

require 'rake/tasklib'
require_relative 'proxy_task'

module Lightspeed

  class DylibTask < Rake::TaskLib

    attr_reader :name, :source_files, :module_name, :module_dependencies

    def initialize(name, source_files, module_name, module_dependencies: [])
      @name = name
      @source_files = source_files
      @module_name = module_name
      @module_dependencies = module_dependencies
    end

    def define
      build_product = create_build_product(module_dependencies + source_files)
      ProxyTask.define_task(name => build_product)
    end

    def create_build_product(deps)
      BuildProductTask.new(name).define.enhance(deps) { |t|
        module_name = t.name.pathmap("%n").sub(/^lib/, '')
        linker_opts = module_dependencies.map { |m| "-l#{m}" }
        swift '-emit-library', '-o', t.name, '-module-name', module_name, *linker_opts, *source_files
      }
    end

  end

end
