require 'rake'

module Lightspeed

  # Build up an underlying module by copying header files and defining a
  # module map.
  #
  class UnderlyingModuleTask < Struct.new(:name, :path, :headers)
    include Rake::DSL

    def header_dir
      @header_dir ||= File.join(path, name)
    end

    def copied_headers
      @copied_headers ||= FileList[headers].pathmap("%{,#{header_dir}/}f")
    end

    def modulemap
      @modulemap ||= File.join(path, "module.modulemap")
    end

    # Clients can depend on this task, which represents all subtasks
    # needed to build the underlying module, instead of knowing
    # individual file paths to depend on.
    def proxy
      "#{name}:underlying_module"
    end

    def define
      directory(path)
      directory(header_dir)

      headers.zip(copied_headers).each do |header, copied_header|
        file(copied_header => [header, header_dir]) do |t|
          cp t.source, t.name
        end
      end

      file(modulemap => path) do |t|
        contents = <<-EOS
module #{name} {
umbrella "#{name}"
module * { export * }
}
EOS
        File.write(t.name, contents)
      end

      ProxyTask.define_task(proxy => [modulemap, *copied_headers])

      self
    end

  end

end
