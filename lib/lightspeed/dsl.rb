# Rake DSL extensions for Swift.

require 'rake'
require_relative 'app_task'
require_relative 'module_task'

module Lightspeed
  module DSL

    # Define a group of tasks for building a swift module. For example,
    # given a module with the name 'Hello', this tasks prerequisites
    # will be a dynamic library libHello.dylib and a swiftmodule file
    # Hello.swiftmodule.
    #
    def swiftmodule(module_name, source_files = FileList["#{module_name}/**/*.swift"])
      ModuleTask.new(module_name, source_files).define
    end

    # Define a group of tasks for building a swift executable.
    #
    # Example:
    #
    #   swiftapp 'hello' => ['Hello', 'World'] do |app|
    #     app.source_files = 'main.swift', 'config.swift'
    #   end
    #
    # This defines the wrapper task 'hello', which will compile the
    # Hello and World modules, then compile the specified source files
    # and link against the compiled modules.
    #
    def swiftapp(*args)
      app = AppTask.new(*args)
      yield app if block_given?
      app.define
    end

  end
end

self.extend(Lightspeed::DSL)
