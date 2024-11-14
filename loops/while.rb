#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../requirements/requirements'

class SproutLoop
end

# Do While are executed at least once, no matter the status of the condition.
# The loop is then executed as long as no break changes the value of @frame.loop
# or the condition is evaluated to false.
class SproutDoWhile < SproutLoop
  def initialize(condition, frame, syntax)
    super()
    @condition = condition
    @syntax_tree = syntax.tree.clone
    @frame = frame
  end

  def evaluate(node)
    return node if node.instance_of? TrueClass or node.instance_of? FalseClass
    return false if node.is_a? SproutInt and node.run.zero?
    return node.run if node.is_a? SproutBool
    return true if node.is_a? SproutMainData

    node.run.run
  end

  def run
    @frame.loop = true
    while @frame.loop
      @syntax_tree.each do |node|
        break unless @frame.loop
        return node if node.is_a? SproutReturn

        final = node.run
        return final if final.is_a? SproutReturn
      end
      break unless evaluate(@condition)
    end
    @frame.loop = false
  end
end

# While-loops only run if the condition is true, the rest is fairly identical to Do While.
class SproutWhile < SproutDoWhile
  def run
    return unless evaluate(@condition)

    super()
  end
end

class SproutBreak
  def initialize(frame)
    @frame = frame
  end

  def execute_break(frame)
    if frame.loop
      frame.loop = false
    elsif frame.parent != NilClass
      execute_break(@frame.parent)
    else
      raise SproutBreakError
    end
  end

  def run
    execute_break(@frame)
  end
end
