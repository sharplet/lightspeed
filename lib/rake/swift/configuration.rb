# Global configuration and build options for Swift.

module Swift

  # Top-level API for configuring Swift build settings.
  #
  # Example:
  #
  #   Swift.configure do |c|
  #     c.sdk = :macosx
  #   end
  #
  def self.configure
    yield Configuration.instance
  end

  # Encapsulates a set of Swift build settings.
  class Configuration

    ### Configurable attributes

    # SDK to compile against.
    attr_accessor :sdk

    # Build locations
    attr_accessor :build_dir, :build_products_dir, :build_intermediates_dir


    ### Initialization

    def self.instance
      @@instance ||= new
    end

    def initialize
      @sdk = :macosx
      @build_dir = 'Build'
    end


    ### SDK paths

    def sdk=(new_sdk)
      @resolved_sdk = nil
      @sdk = new_sdk
    end

    def resolve_sdk
      @resolved_sdk ||=
        case sdk
        when :macosx, :iphoneos, :iphonesimulator
          %x(xcrun --sdk #{sdk.to_s} --show-sdk-path).chomp
        else
          fail "Unknown SDK Error"
        end
    end

    def self.sdk
      instance.resolve_sdk
    end


    ### Build locations

    def self.build_products_dir
      instance.build_products_dir
    end

    def build_intermediates_dir
      @build_intermediates_dir ||= "#{build_dir}/Intermediates"
    end

    def build_products_dir
      @build_products_dir ||= "#{build_dir}/Products"
    end

  end

end
