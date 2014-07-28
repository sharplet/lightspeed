# Rake DSL extensions for Swift.

require 'rake'
require_relative 'module_task'

module Swift
  module DSL

    # Define a group of tasks for building a swift module. For example,
    # given a module with the name 'Hello', this tasks prerequisites
    # will be a dynamic library libHello.dylib and a swiftmodule file
    # Hello.swiftmodule.
    #
    def swiftmodule(module_name, source_files = FileList["#{module_name}/**/*.swift"])
      ModuleTask.new(module_name, source_files).define
    end

  end
end

self.extend(Swift::DSL)
