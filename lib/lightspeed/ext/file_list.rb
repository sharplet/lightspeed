# Extensions to FileList

require 'rake'

class FileList

  # Shift all patterns/paths relative to the provided base directory.
  #
  # Example:
  #   FileList.relative_to("vendor/foo", "Foo/**/*.swift")
  #
  def self.relative_to(base, *paths)
    unless base == Dir.pwd
      paths = paths.map { |path| File.join(base, path) }
    end
    new(*paths)
  end

end
