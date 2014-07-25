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

    # SDK to compile against.
    attr_accessor :sdk

    def self.instance
      @@instance ||= new
    end

    def initialize
      @sdk = :macosx
    end

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

  end

end
