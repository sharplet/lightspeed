# Rake extensions for compiling Swift files and modules.

# Tasks
require_relative 'lightspeed/app_task'
require_relative 'lightspeed/framework_task'
require_relative 'lightspeed/proxy_task'

# Configuration
require_relative 'lightspeed/configuration'

# DSL
require_relative 'lightspeed/dsl'

# Extensions
require_relative 'lightspeed/ext/file_utils'

# Load user dependencies
require_relative 'lightspeed/loader'
Lightspeed::Loader.load
