# Compiles a .swiftmodule file from Swift source file dependencies.

require 'rake'

module Swift
  class SwiftmoduleTask < Rake::FileTask

    extend FileUtils

    def self.define_task(*args, &block)
      t = super(*args) do |t|
        swift '-emit-module', '-o', t.name, '-module-name', t.name.ext, *t.sources
      end
      t.enhance(&block)
    end

  end
end
