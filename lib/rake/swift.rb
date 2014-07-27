# Rake extensions for compiling Swift files and modules.

# Tasks
require_relative 'swift/build_product_task'
require_relative 'swift/dylib_task'
require_relative 'swift/module_task'
require_relative 'swift/proxy_task'
require_relative 'swift/swiftmodule_task'

# Configuration
require_relative 'swift/configuration'

# DSL
require_relative 'swift/dsl'

# Extensions
require_relative 'swift/file_utils_ext'
