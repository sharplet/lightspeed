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

  # If a file exists, return the argument, otherwise return nil.
  def ensure_exists(file)
    File.exist?(file) ? file : nil
  end

end
