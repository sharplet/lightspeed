# Rake DSL extensions for Swift.

require 'rake'
require_relative 'app_task'
require_relative 'framework_task'

module Lightspeed
  module DSL

    # Define a group of tasks for building a swift executable.
    #
    # Example:
    #
    #   swiftapp 'hello' => ['Hello.framework', 'World.framework'] do |app|
    #     app.source_files = 'main.swift', 'config.swift'
    #   end
    #
    # This defines the wrapper task 'hello', which will compile the
    # Hello and World frameworks, then compile the specified source files.
    #
    def swiftapp(*args)
      name, _, deps = *Rake.application.resolve_args(args)
      app = AppTask.new(name, deps)
      yield app if block_given?
      app.define
    end

    # Define a group of tasks for building a swift framework.
    #
    # Example:
    #
    #   framework 'Hello'   # => builds all source files in the Hello/
    #                            directory
    #
    #   framework 'World' => 'Hello.framework' do
    #     f.source_files = "world.swift", "World/*.swift"
    #   end
    #
    def framework(*args)
      name, _, deps = *Rake.application.resolve_args(args)
      f = FrameworkTask.new(name, deps)
      yield f if block_given?
      f.define
    end

  end
end

self.extend(Lightspeed::DSL)
