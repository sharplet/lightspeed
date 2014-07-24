# A SwiftmoduleTask represents two file tasks: a dynamic library and an
# associated .swiftmodule file.

require 'rake'
require_relative 'group_task'

module Swift

  class SwiftmoduleTask < Rake::Task
    include GroupTask

    class << self

      def define_task(*args, &block)
        t = super(*args, &block)
        deps = make_module_deps(t.name)
        t.enhance(deps)
      end

      def make_module_deps(module_name)
        [module_name.pathmap("%{,lib}n.dylib"), module_name.ext('.swiftmodule')]
      end

    end

  end

end
