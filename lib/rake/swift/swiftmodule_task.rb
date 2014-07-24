# A SwiftmoduleTask represents two file tasks: a dynamic library and an
# associated .swiftmodule file.

require 'rake'
require_relative 'group_task'
require_relative 'dylib_task'

module Swift
  class SwiftmoduleTask < Rake::Task

    include GroupTask

    def self.define_task(*args, &block)
      t = super(*args, &block)
      deps = make_module_deps(t.name)
      t.enhance(deps)
    end

    def self.make_module_deps(module_name)
      dylib = dylib_name(module_name)
      [DylibTask.define_task(dylib), module_name.ext('.swiftmodule')]
    end

    def self.dylib_name(name)
      name.sub(/^(?!lib)/, 'lib').ext('.dylib')
    end

  end
end
