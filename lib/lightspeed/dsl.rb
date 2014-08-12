# Rake DSL extensions for Swift.

require 'rake'
require_relative 'app_task'
require_relative 'module_task'

module Lightspeed
  module DSL

    def framework(*args)
      name, _, deps = *Rake.application.resolve_args(args)
      f = FrameworkTask.new(name, deps)
      yield f if block_given?
      f.define
    end

    # Define a group of tasks for building a swift module. For example,
    # given a module with the name 'Hello', this tasks prerequisites
    # will be a dynamic library libHello.dylib and a swiftmodule file
    # Hello.swiftmodule.
    #
    def swiftmodule(*args)
      name, _, deps = *Rake.application.resolve_args(args)
      mod = ModuleTask.define(name, deps)
      yield mod if block_given?
      mod.define
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
      name, _, deps = *Rake.application.resolve_args(args)
      app = AppTask.new(name, deps)
      yield app if block_given?
      app.define
    end

  end
end

self.extend(Lightspeed::DSL)
