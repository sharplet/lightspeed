# An enumerable whose contents are lazily evaluated the first time it is
# used.

module Lightspeed
  class FutureList
    include Enumerable

    def initialize(&block)
      @block = block
    end

    def each(&block)
      resolve.each(&block)
    end

    def force
      resolve
    end

    def to_a
      each.to_a
    end

    alias_method :to_ary, :to_a

    def +(other_ary)
      to_a + other_ary
    end

    private

    def resolve
      @list ||= block.call.tap { @resolved = true }
    end

    attr_reader :block, :list, :resolved

  end
end
