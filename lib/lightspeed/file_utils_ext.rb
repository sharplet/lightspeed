# Swift extensions for the FileUtils module.

module FileUtils

  # Runs the swift compiler with the given arguments. SDK search paths and
  # use of 'xcrun' are managed automatically.
  #
  # Example:
  #   swift "Hello.rake -o hello"
  #
  def swift(*args)
    sdk_opts = ['-sdk', Swift::Configuration.sdk]
    build_products = Swift::Configuration.build_products_dir
    linker_opts = ["-L#{build_products}"]
    module_opts = ["-I#{build_products}"]

    all_opts = sdk_opts + linker_opts + module_opts + args

    if args.count == 1 && args.first.to_s.include?(" ")
      sh "xcrun swift #{all_opts.join(" ")}"
    else
      sh "xcrun", "swift", *all_opts
    end
  end

end
