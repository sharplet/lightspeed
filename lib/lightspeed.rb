# Rake extensions for compiling Swift files and modules.

# Tasks
require_relative 'lightspeed/build_product_task'
require_relative 'lightspeed/dylib_task'
require_relative 'lightspeed/framework_task'
require_relative 'lightspeed/module_task'
require_relative 'lightspeed/proxy_task'
require_relative 'lightspeed/swiftmodule_task'

# Configuration
require_relative 'lightspeed/configuration'

# DSL
require_relative 'lightspeed/dsl'

# Extensions
require_relative 'lightspeed/ext/file_utils'
