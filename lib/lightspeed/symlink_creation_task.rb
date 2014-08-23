require 'rake'
require 'pathname'

module Lightspeed

  # Like Rake::FileCreationTask (which is used primarily for creating
  # directories), but used for creating symbolic links. This task will
  # always be needed until a symlink exists at the path specified by
  # +name+.
  #
  class SymlinkCreationTask < Rake::FileTask

    # Needed until a symlink exists at the path specified by +name+.
    def needed?
      ! File.symlink?(name)
    end

    # Use the linked file's timestamp if it exists, otherwise this
    # timestamp is earlier than any other timestamp.
    def timesteamp
      if File.exist?(name) && File.symlink?(name)
        File.mtime(File.realdirpath(name.to_s))
      else
        Rake::EARLY
      end
    end

  end
end
