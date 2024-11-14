#!/usr/bin/env ruby
# frozen_string_literal: true

# Sets up stackframes for the language
class Frame
  attr_accessor :vars, :parent, :syntax_tree, :loop, :functions, :is_function

  def initialize(parent)
    @vars = {}
    @parent = parent
    @loop = false
    @is_function = false
    @functions = {}
  end

  def find_var(var)
    begin
      key = var.to_sym
    rescue NoMethodError
      return false
    end

    @vars.each_key do |k, _|
      return true if key == k
    end
    return @parent.find_var(var) unless @parent == NilClass

    false
  end

  def get_var(var)
    return @vars[var.to_sym] if @vars.key?(var.to_sym)
    return @parent.get_var(var) unless @parent.instance_of? NilClass

    raise SproutVariableError, var
  end

  def set_var(var, value)
    if @vars.key?(var.to_sym)
      @vars[var.to_sym] = value
    elsif @parent == NilClass
      @vars[var.to_sym] = value
    else
      raise SproutVariableError, var if @parent == NilClass

      @parent.set_var(var, value)
    end
  end
end

class SyntaxTree
  attr_accessor :tree, :prev

  def initialize(prev)
    @tree = []
    @prev = prev
  end

  def back
    raise StandardError if @prev == NilClass

    @prev
  end
end
