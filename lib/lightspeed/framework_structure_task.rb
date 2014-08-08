require 'rake'
require 'rake/tasklib'

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
      define_link_tasks
      define_proxy_task
      self
    end

    ## Create directory structure

    def define_directory_tasks
      dirs.each { |dir| directory(dir) }
    end

    def dirs
      [path, latest_version_path, modules_path, headers_path].compact
    end
    private :dirs

    ## Create links

    def define_link_tasks
      @links = [
        file("#{path}/Versions/Current" => latest_version_path) { |t|
          ln_s t.source.pathmap("%n"), t.name
        },
        file("#{path}/#{basename}") { |t| ln_s "Versions/Current/#{basename}", t.name },
        (file("#{path}/Modules") { |t| ln_s "Versions/Current/Modules", t.name } unless swift_sources.empty?),
        (file("#{path}/Headers") { |t| ln_s "Versions/Current/Headers", t.name } unless header_files.empty?),
      ].compact.map(&:name)
    end

    attr_reader :links
    private     :links

    ## Create proxy task

    def define_proxy_task
      ProxyTask.define_task(name => [*dirs, *links])
    end

    ## Framework paths

    def latest_version_path
      File.join(path, "Versions", "A")
    end

    def modules_path
      File.join(latest_version_path, "Modules", "#{basename}.swiftmodule") unless swift_sources.empty?
    end

    def headers_path
      File.join(latest_version_path, "Headers") unless header_files.empty?
    end

    def current_version_path
      File.join(path, "Versions", "Current")
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
