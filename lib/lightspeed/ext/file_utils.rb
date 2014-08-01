# Swift extensions for the FileUtils module.

require_relative '../swift_command'

module FileUtils

  # Runs the swift compiler with the given arguments. SDK search paths and
  # use of 'xcrun' are managed automatically.
  #
  # Example:
  #   swift "Hello.rake -o hello"
  #
  def swift(*args)
    Lightspeed::SwiftCommand.new(args).build do |*cmd|
      sh(*cmd)
    end
  end

end
