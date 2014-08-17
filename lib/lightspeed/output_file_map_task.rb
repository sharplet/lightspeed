require 'rake'
require 'json'

module Lightspeed

  # Generate an output file map as a JSON manifest. Used by swiftc to
  # define the locations of object files.
  #
  class OutputFileMapTask < Struct.new(:name, :source_files, :object_files)
    include Rake::DSL

    def define
      file(name) do |t|
        dict = source_files.zip(object_files).reduce({}) { |dict, (source, object)|
          dict.merge({ source => { "object" => object } })
        }
        File.write(t.name, dict.to_json + "\n")
      end
      self
    end

  end

end
