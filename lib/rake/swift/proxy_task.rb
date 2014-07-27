# A proxy task is needed only if its prerequisites are needed, and
# reports the same timestamp of its most recently modified prerequisite.

require 'rake'

module Swift
  module ProxyTask

    def needed?
      prerequisite_tasks.any?(&:needed?)
    end

    def timestamp
      prerequisite_tasks.map(&:timestamp).inject(Rake::EARLY) { |latest, pre| [latest, pre].max }
    end

  end
end
