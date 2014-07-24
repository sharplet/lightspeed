module Swift
  class DylibTask < Rake::FileTask

    include FileUtils

    def self.define_task(*args, &block)
      t = super(*args, &block)
      t.define_prerequisites
      t.define_action
    end

    attr_reader :swift_sources
    private     :swift_sources

    def initialize(*args)
      super(*args)
      @swift_sources = FileList["#{module_name}/**/*.swift"]
    end

    def module_name
      @module_name ||= name.pathmap("%n").sub(/^lib/, '')
    end

    def define_prerequisites
      sources_and_objects.each do |src, obj|
        Rake::FileTask.define_task(obj => src) do |t|
          swift t.source, '-emit-object', '-o', t.name, '-module-name', module_name
        end
        enhance([obj])
      end
    end

    def sources_and_objects
      objects = swift_sources.ext('.o')
      swift_sources.zip(objects)
    end

    def define_action
      enhance do |t|
        sh 'swift', '-emit-library', '-o', t.name, *t.sources, '-module-name', module_name
      end
    end

  end
end
