# Construct a swift compiler command.

module Lightspeed
  class SwiftCommand
    include FileUtils

    COMPILER_MODES = {
      compiled: 'swiftc',
      immediate: 'swift',
    }

    attr_reader :args, :mode, :config

    def initialize(args, mode: :compiled, config: Lightspeed.configuration)
      @args = args
      @mode = COMPILER_MODES.fetch(mode) { fail ArgumentError, "unsupported swift compiler mode '#{mode}'" }
      @config = config
    end

    def build
      if block_given?
        yield *format_cmd
      else
        format_cmd
      end
    end

    private

    def format_cmd
      other_opts = framework_opts + linker_opts + import_opts + args
      cmd = ['xcrun', *sdk_opts, mode, *other_opts]
      if args.count == 1 && args.first.to_s.include?(" ")
        cmd = cmd.join(" ")
      else
        cmd
      end
    end

    def sdk_opts
      ['-sdk', config.sdk.to_s]
    end

    def framework_opts
      [ *map_if?(build_dir) { |dir| "-F#{dir}" } ]
    end

    def linker_opts
      [ *map_if?(build_dir) { |dir| "-L#{dir}" } ]
    end

    def import_opts
      [ *map_if?(build_dir) { |dir| "-I#{dir}" } ]
    end

    def build_dir
      ensure_exists(config.build_products_dir)
    end

    # If the value is truthy, map with the provided block, else return nil.
    def map_if?(val, &block)
      if val
        yield val
      end
    end

  end
end
