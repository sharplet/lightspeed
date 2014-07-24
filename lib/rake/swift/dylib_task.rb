# Emits a Swift dynamic library by linking its object file dependencies.

module Swift
  class DylibTask < Rake::FileTask

    extend FileUtils

    def self.define_task(*args, &block)
      t = super(*args) do |t|
        module_name = t.name.pathmap("%n").sub(/^lib/, '')
        sh 'swift', '-emit-library', '-o', t.name, *t.sources, '-module-name', module_name
      end
      t.enhance(&block)
    end

    def self.synthesize_object_file_dependencies(source_files, module_name)
      object_files = source_files.ext('.o')
      sources_and_objects = source_files.zip(object_files)
      object_file_tasks = sources_and_objects.map { |src, obj|
        Rake::FileTask.define_task(obj => src) { |t|
          swift t.source, '-emit-object', '-o', t.name, '-module-name', module_name
        }
      }
      object_file_tasks.map(&:name)
    end

  end
end
