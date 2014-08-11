require 'rake'
require 'rake/tasklib'

require_relative 'symlink_creation_task'
require_relative 'proxy_task'

module Lightspeed
  class FrameworkStructureTask < Rake::TaskLib

    attr_reader :name, :path, :basename

    attr_accessor :swift_sources, :header_files

    def initialize(name, path)
      @name = name
      @path = path
      @basename = path.pathmap("%n")
      yield self if block_given?
    end

    def define
      define_directory_tasks
      define_header_tasks
      define_link_tasks
      define_proxy_task
      self
    end

    ## Create directory structure

    def define_directory_tasks
      dirs.each { |dir| directory(dir) }
    end

    def dirs
      @dirs ||= [path, latest_version_path, modules_path, swiftmodules_path, headers_path].compact
    end
    private :dirs

    ## Copy header files

    def define_header_tasks
      @headers = header_files.map { |header|
        header_name = header.pathmap("%f")
        header_path = File.join(headers_path, header_name)
        file(header_path => [header, headers_path]) do |t|
          cp t.source, t.name
        end
        header_path
      }

      if umbrella_header = @headers.find { |header| header.pathmap("%n") == basename }
        modulemap_path = File.join(modules_path, "module.modulemap")
        file(modulemap_path => [umbrella_header, modules_path]) do |t|
          contents = <<-EOS
framework module #{basename} {
  umbrella header "#{t.source.pathmap("%f")}"

  export *
  module * { export * }
}
EOS
          File.write(t.name, contents)
        end
        @headers.push(modulemap_path)
      end
    end

    attr_reader :headers
    private     :headers

    ## Create links

    def define_link_tasks
      @links = [
        symlink_create("#{path}/Versions/Current" => latest_version_path) { |t|
          ln_s t.source.pathmap("%n"), t.name
        },
        symlink_create("#{path}/#{basename}" => "#{path}/Versions/Current") { |t|
          ln_s "Versions/Current/#{basename}", t.name
        },
        (symlink_create("#{path}/Modules") { |t|
          ln_s "Versions/Current/Modules", t.name } unless (header_files + swift_sources).empty?),
        (symlink_create("#{path}/Headers") { |t|
          ln_s "Versions/Current/Headers", t.name } unless header_files.empty?),
      ].compact.map(&:name)
    end

    attr_reader :links
    private     :links

    def symlink_create(*args, &block)
      Lightspeed::SymlinkCreationTask.define_task(*args, &block)
    end
    private :symlink_create

    ## Create proxy task

    def define_proxy_task
      ProxyTask.define_task(name => [*dirs, *headers, *links].compact)
    end

    ## Framework paths

    def latest_version_path
      @latest_version_path ||= File.join(path, "Versions", "A")
    end

    def modules_path
      @modules_path ||= File.join(latest_version_path, "Modules") unless header_files.empty?
    end

    def swiftmodules_path
      @swiftmodules_path ||= File.join(modules_path, basename.ext('.swiftmodule')) unless swift_sources.empty?
    end

    def headers_path
      @headers_path ||= File.join(latest_version_path, "Headers") unless header_files.empty?
    end

    def current_version_path
      @current_version_path ||= File.join(path, "Versions", "Current")
    end

    ## Default values

    def swift_sources
      @swift_sources ||= []
    end

    def header_files
      @header_files ||= []
    end

  end
end
