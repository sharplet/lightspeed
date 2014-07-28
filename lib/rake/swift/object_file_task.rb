# Create an object file from a Swift source file.

require_relative 'build_product_task'

module Swift
  class ObjectFileTask < BuildProductTask

    attr_reader :source, :module_name, :config

    def initialize(from_source: nil, module_name: "", config: Configuration.instance)
      fail ArgumentError, "source must not be nil" if not from_source
      @source = from_source
      @module_name = module_name
      super(make_name, config: config)
    end

    def define
      super.enhance([source]) { |t|
        opts = [source, '-emit-object', '-o', t.name]
        opts += ['-module-name', module_name] unless module_name.empty?
        swift(*opts)
      }
    end

    def build_product
      File.join(config.build_intermediates_dir, name)
    end

    private

    def make_name
      components = [module_build_dir, source.ext('.o')].reject(&:empty?)
      File.join(*components)
    end

    def module_build_dir
      case module_name
      when "", nil then ""
      else "#{module_name}.build"
      end
    end

  end
end
