# Find and load lightspeed dependency files

require 'rake'

module Lightspeed

  # Searches for lightspeed.rake dependency files and evaluates them
  # against the Lightspeed DSL. Lightspeed depfiles are not intendended
  # to be full-blown Rakefiles.
  #
  class Loader

    # Instantiate a new loader with the default search paths and
    # immediately load depfiles.
    #
    def self.load
      new(FileList['.', 'vendor/*']).load
    end

    def initialize(search_paths)
      @search_paths = FileList.new(search_paths.select { |path| File.directory?(path) })
    end

    def load
      depfiles.map { |path| [File.expand_path(path), File.read(path)] }.each do |file, contents|
        base_dir = file.pathmap("%d")
        config.with_base_dir(base_dir) do
          dsl_proxy.instance_eval(contents, file)
        end
      end
    end

    private

    attr_reader :search_paths

    def depfiles
      @depfiles ||= FileList[search_paths.pathmap("%p/lightspeed.{rb,rake}")]
    end

    def config
      Lightspeed.configuration
    end

    def dsl_proxy
      Object.new.extend(DSL).tap do |proxy|
        proxy.instance_eval do
          def inspect
            "lightspeed"
          end
        end
      end
    end

  end

end
