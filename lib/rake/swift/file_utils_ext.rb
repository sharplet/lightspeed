# Swift extensions for the FileUtils module.

module FileUtils

  # Runs the swift compiler with the given arguments. SDK search paths and
  # use of 'xcrun' are managed automatically.
  #
  # Example:
  #   swift "Hello.rake -o hello"
  #
  def swift(*args)
    sdk = %x(xcrun --show-sdk-path --sdk macosx).chomp
    if args.count == 1 && args.first.to_s.include?(" ")
      sh "xcrun swift #{args.first.to_s} -sdk #{sdk}"
    else
      sh "xcrun", "swift", *args, "-sdk", sdk
    end
  end

end
