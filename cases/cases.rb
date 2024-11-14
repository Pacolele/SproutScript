#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../requirements/requirements'

# This file contains all nodes that connect different parts of the syntax tree

class SproutCaseNode
  def initialize(frame)
    @frame = frame
    @syntax_tree = []
  end
end

class SproutIfNode < SproutCaseNode
  attr_accessor :else, :syntax_tree

  def append_statement(node)
    if @else == NilClass
      @else = node
    else
      @else.append_statement(node)
    end
  end

  def initialize(condition, frame, syntax)
    super(frame)
    @condition = condition
    @syntax_tree = syntax.tree.clone
    @else = NilClass
  end

  def run
    current_condition = if @condition == true
                          true
                        else
                          @condition.run.run
                        end

    if current_condition
      @syntax_tree.each do |node|
        return node if node.is_a? SproutReturn

        final = node.run
        return final if final.is_a? SproutReturn
      end
    elsif @else != NilClass
      @else.run
    end
  end
end
