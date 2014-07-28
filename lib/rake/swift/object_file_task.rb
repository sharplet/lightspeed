# Create an object file from a Swift source file.

module Swift

  class ObjectFileTask < Rake::TaskLib

    attr_reader :source, :name, :module_name, :config

    def initialize(source, module_name: "", config: Configuration.instance)
      @source = source
      @name = source.ext('.o')
      @module_name = module_name
      @config = config
    end

    def define
      build_dir, _ = *build_product.rpartition(File::SEPARATOR)
      dir = directory(build_dir)
      compile = compile_task(build_product => [source, dir.name])
    end

    def build_product
      File.join(config.resolve_build_intermediates_dir(module_name), name)
    end

    private

    def compile_task(*args, &block)
      t = file(*args) { |t|
        opts = [t.source, '-emit-object', '-o', t.name]
        opts += ['-module-name', module_name] unless module_name.empty?
        swift(*opts)
      }
      t.enhance(&block)
    end
  end

end
