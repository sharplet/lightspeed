require 'rake/tasklib'
require 'json'

module Lightspeed
  class FrameworkTask < Rake::TaskLib

    attr_reader :name, :basename, :config, :arch

    attr_accessor :source_files

    def initialize(name, config: Lightspeed.configuration)
      @basename = name.pathmap("%n")
      @name = basename.ext(".framework")
      @config = config
      @arch = "x86_64"
    end

    def define
      base = directory("#{config.build_products_dir}/#{name}").name
      current = directory("#{base}/Versions/A").name
      modules = directory("#{current}/Modules/#{basename}.swiftmodule").name unless swift_sources.empty?
      headers = directory("#{current}/Headers").name unless header_files.empty?

      build_dir = directory(config.target_build_dir(basename)).name
      output_file_map = "#{build_dir}/output-file-map.json"
      sources_to_objects  = swift_sources.reduce({}) { |dict, source|
        dict.merge({ source => source.pathmap("%{,#{build_dir}/}X.o") })
      }
      file(output_file_map => [*swift_sources, build_dir]) do |t|
        dict = sources_to_objects.reduce({}) { |dict, (source, object)|
          dict.merge({ source => { "object" => object } })
        }
        File.write(t.name, dict.to_json + "\n")
      end

      object_files = sources_to_objects.values
      object_dirs = FileList[object_files].pathmap("%d").each { |d| directory(d) }

      swiftc_task = task("#{name}:swift_objects" => [output_file_map, *object_dirs, *swift_sources]) { |t|
        swift "-c",
          "-module-name", basename,
          "-emit-module", "-emit-module-path", "#{modules}/#{arch}.swiftmodule",
          "-output-file-map", output_file_map,
          "--", *swift_sources
      }

      swiftc_task.define_singleton_method(:needed?) do
        sources_to_objects.reduce(false) { |needed, (source, object)|
          needed ? true : Rake::Task[source].timestamp > Rake::Task[object].timestamp
        }
      end

      object_files.each { |object| file(object => swiftc_task) }

      linker_task = file("#{current}/#{basename}" => [current, *object_files]) { |t|
        swift "-emit-library", "-o", t.name, "--", *object_files
      }

      current_version = file("#{base}/Versions/Current" => "#{base}/Versions/A") { |t|
        ln_s t.source.pathmap("%n"), t.name
      }
      executable_link = file("#{base}/#{basename}") { |t|
        ln_s "Versions/Current/#{basename}", t.name
      }
      modules_link = file("#{base}/Modules") { |t|
        ln_s "Versions/Current/Modules", t.name
      } unless swift_sources.empty?
      headers_link = file("#{base}/Headers") { |t|
        ln_s "Versions/Current/Headers", t.name
      } unless header_files.empty?

      dirs = [base, current, modules, headers].compact
      links = [current_version, executable_link, modules_link, headers_link].compact

      structure = ProxyTask.define_task("#{name}:structure" => [*dirs, *links])

      ProxyTask.define_task(name => [structure, linker_task])
    end

    def source_files
      @source_files ||= FileList.new
    end
    def source_files=(*args)
      @source_files = FileList[*args.flatten]
    end

    def header_files
      @header_files ||= source_files.select { |f| File.extname(f) == ".h" }
    end

    def swift_sources
      @swift_sources ||= source_files.select { |f| File.extname(f) == ".swift" }
    end

  end
end
