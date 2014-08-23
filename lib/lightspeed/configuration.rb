# Global configuration and build options for Swift.

module Lightspeed

  # Top-level API for configuring Swift build settings.
  #
  # Example:
  #
  #   Lightspeed.configure do |c|
  #     c.sdk = :macosx
  #   end
  #
  def self.configure
    yield Configuration.instance
  end

  # Access the shared configuration.
  def self.configuration
    Configuration.instance
  end

  # Encapsulates a set of Swift build settings.
  class Configuration

    ### Configurable attributes

    # SDK to compile against.
    attr_accessor :sdk

    # Build locations
    attr_accessor :build_dir,
                  :build_intermediates_dir,
                  :build_products_dir,
                  :executables_dir


    ### Initialization

    def self.instance
      @@instance ||= new
    end

    def initialize
      @sdk = :macosx
      @build_dir = 'Build'
    end


    ### SDK paths

    def self.sdk
      instance.sdk
    end


    ## Source file location

    def base_dir
      @base_dir || Dir.pwd
    end

    def with_base_dir(base_dir, &block)
      @base_dir = base_dir
      yield
      @base_dir = nil
    end


    ### Build locations

    def executables_dir
      @executables_dir ||= "bin"
    end

    def build_products_dir
      @build_products_dir ||= File.join(build_dir, "Products")
    end

    def build_intermediates_dir
      @build_intermediates_dir ||= File.join(build_dir, "Intermediates")
    end

    def target_build_dir(target)
      File.join(build_intermediates_dir, target.ext(".build"))
    end

  end

end
