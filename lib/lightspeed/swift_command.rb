# Construct a swift compiler command.

module Lightspeed
  class SwiftCommand

    attr_reader :args, :config

    def initialize(args, config: Lightspeed.configuration)
      @args = args
      @config = config
    end

    def build
      cmd = format_cmd
      if block_given?
        yield *cmd
      else
        cmd
      end
    end

    private

    def format_cmd
      all_opts = sdk_opts + linker_opts + import_opts + args
      cmd = ['xcrun', 'swift', *all_opts]
      if args.count == 1 && args.first.to_s.include?(" ")
        cmd = cmd.join(" ")
      else
        cmd
      end
    end

    def sdk_opts
      ['-sdk', config.sdk]
    end

    def linker_opts
      ["-L#{config.build_products_dir}"]
    end

    def import_opts
      ["-I#{config.build_products_dir}"]
    end

  end
end
