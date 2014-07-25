# Swift extensions for the FileUtils module.

module FileUtils

  # Runs the swift compiler with the given arguments. SDK search paths and
  # use of 'xcrun' are managed automatically.
  #
  # Example:
  #   swift "Hello.rake -o hello"
  #
  def swift(*args)
    sdk = Swift::Configuration.sdk
    if args.count == 1 && args.first.to_s.include?(" ")
      sh "xcrun swift -sdk #{sdk} #{args.first.to_s}"
    else
      sh "xcrun", "swift", "-sdk", sdk, *args
    end
  end

end
