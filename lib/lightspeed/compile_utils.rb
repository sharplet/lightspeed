require 'rake'

module Lightspeed

  module CompileUtils

    def object_files_for(source_files, relative_to: nil)
      source_files.map { |f| object_file_for(f, relative_to: relative_to) }
    end

    def object_file_for(source_file, relative_to: nil)
      expand = relative_to ? "{,#{relative_to}/}" : ""
      source_file.pathmap("%#{expand}X.o")
    end

    def directories_containing(files)
      FileList[files].pathmap("%d").uniq
    end

  end

end
