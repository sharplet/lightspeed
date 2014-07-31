require 'set'

module Lightspeed
  class LinkableNode

    attr_reader :name, :children

    def initialize(name, children = [])
      @name = name
      @children = children
    end

    def modules
      fold(Set.new) { |lib_sets, child|
        [Set.new(child.children), *lib_sets].inject(:+)
      }.to_a
    end

    ## Folding over nodes

    def leaf?
      children.none?
    end

    def fold(leaf_result, &combine_results)
      if leaf?
        leaf_result
      else
        child_results = child_nodes.map { |child|
          child.fold(leaf_result, &combine_results)
        }
        yield child_results, self
      end
    end

    def child_nodes
      children.map { |child| lookup_node(child) }
    end

    ## Support for building a shared cache of linkable nodes keyed by name.

    TREE_NODES ||= Hash.new

    def self.[](name)
      TREE_NODES.fetch(name)
    end

    def lookup_node(name)
      self.class[name]
    end

    def self.define(name, children = [])
      TREE_NODES[name] = new(name, children)
    end

  end
end
