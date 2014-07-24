# Rake DSL extensions for Swift.

require 'rake'
require_relative 'swiftmodule_task'

module Swift
  module DSL

    # Define a group of tasks for building a swift module. For example,
    # given a module with the name 'Hello', this tasks prerequisites
    # will be a dynamic library libHello.dylib and a swiftmodule file
    # Hello.swiftmodule.
    #
    def swiftmodule(*args, &block)
      Swift::SwiftmoduleTask.define_task(*args, &block)
    end

  end
end

self.extend(Swift::DSL)
