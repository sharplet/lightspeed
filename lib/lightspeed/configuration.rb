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
    attr_accessor :build_dir, :executables_dir
    alias_method :build_products_dir, :build_dir


    ### Initialization

    def self.instance
      @@instance ||= new
    end

    def initialize
      @sdk = :macosx
      @build_dir = 'Build'
    end


    ### SDK paths

    def sdk
      resolve_sdk
    end

    def sdk=(new_sdk)
      @resolved_sdk = nil
      @sdk = new_sdk
    end

    def resolve_sdk
      @resolved_sdk ||=
        case @sdk
        when :macosx, :iphoneos, :iphonesimulator
          %x(xcrun --sdk #{@sdk.to_s} --show-sdk-path).chomp
        else
          fail "Unknown SDK Error"
        end
    end

    def self.sdk
      instance.sdk
    end


    ### Build locations

    def executables_dir
      @executables_dir ||= "bin"
    end

  end

end
