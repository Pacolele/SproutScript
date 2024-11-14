#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../requirements/requirements'

class SproutFor
  def initialize(var, condition, increment, frame, syntax)
    @var = var
    @condition = condition
    @increment = increment
    @syntax_tree = syntax.tree.clone
    @frame = frame
  end

  def evaluate(node)
    return node if node.instance_of? TrueClass or node.instance_of? FalseClass
    return false if node.is_a? SproutInt and node.run.zero?
    return true if node.is_a? SproutMainData

    node.run.run
  end

  def run
    @var.run
    return unless evaluate(@condition)

    @frame.loop = true
    while @frame.loop
      @frame.loop = false unless evaluate(@condition)
      # @syntax_tree.append(@frame.vars[@var] = count) if evaluate(@condition)
      @syntax_tree.each do |node|
        break unless @frame.loop
        return node if node.is_a? SproutReturn

        final = node.run
        return final if final.is_a? SproutReturn
      end
      @frame.set_var(@var.name, @increment.run)
    end
    @frame.loop = false unless evaluate(@condition)
  end
end
