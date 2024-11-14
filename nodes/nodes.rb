#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../requirements/requirements'

# This file contains all nodes that connect different parts of the syntax tree

class ProgramRoot
end

class Node
  # previously named process_data
  # function slimmed down, now only fetches variable (if possible), runs node (if applicable)
  # then runs value to get actual value - kept as a function to avoid DRY
  def get_data(node)
    current = node
    raise SproutVariableError, current if current.instance_of? String and !@frame.find_var(current)

    if @frame.find_var(current) and (current.instance_of? String or current.instance_of? Symbol)
      current = @frame.get_var(current)
    end
    while true
      unless current.is_a? Node or current.is_a? SproutMainData or current.is_a? SproutFunctions or current.is_a? SproutFunctionCall
        break
      end

      current = current.run
    end
    current
  end

  def get_node(node)
    current = node
    if @frame.find_var(current) and (current.instance_of? String or current.instance_of? Symbol)
      current = @frame.get_var(current)
    end
    while true
      break unless current.is_a? Node or current.is_a? SproutFunctions or current.is_a? SproutFunctionCall

      current = current.run
    end
    current
  end
end

# ===== Aritmetics =====
class SproutArithmetic < Node
  attr_reader :lhs, :rhs, :op

  def initialize(lhs, op, rhs, frame)
    super()
    @frame = frame
    @lhs = lhs
    @rhs = rhs
    @op = op
  end

  def run
    lhs_current = get_data(@lhs)
    rhs_current = get_data(@rhs)

    if lhs_current.instance_of? String and rhs_current.instance_of? String
      raise SproutStringOperatorError unless @op == '+'

      SproutString.new(lhs_current.send(@op, rhs_current))
    elsif lhs_current.instance_of? String and rhs_current.instance_of? Integer
      raise SproutStringOperatorError unless @op == '*'

      SproutString.new(lhs_current.send(@op, rhs_current))
    elsif lhs_current.instance_of? Integer and rhs_current.instance_of? Integer
      SproutInt.new(lhs_current.send(@op.to_sym, rhs_current))
    elsif lhs_current.instance_of? Float or rhs_current.instance_of? Float
      SproutFloat.new(lhs_current.send(@op.to_sym, rhs_current))
    end
  end

  def method_missing(*args)
    @frame.vars[args[0].to_sym]
  end
end

# ===== Comparison / Logical =====
class SproutComparison < Node
  def initialize(lhs, op, rhs, frame)
    super()
    @lhs = lhs
    @op = op
    @rhs = rhs
    @frame = frame
  end

  def run
    lhs_current = get_data(@lhs)
    rhs_current = get_data(@rhs)
    SproutBool.new(lhs_current.send(@op.to_sym, rhs_current))
  end
end

class SproutLogicNode < Node
  attr_reader :lhs, :rhs

  def initialize(lhs, op, rhs, frame)
    @lhs = lhs
    @op = op
    @rhs = rhs
    @frame = frame
    @result = NilClass
  end

  # overriding function as we here need to return the actual basic data node rather than the value
  # may change depending on how these nodes later are utilized
  def get_data(value)
    current = value
    current = @frame.get_var(current) if current.is_a? String
    current = current.run if current.is_a? SproutFunctionCall
    current = current.run if current.is_a? Node
    current
  end

  # this function ensures that bools are returned as is, integers are true unless zero, all other data is true
  # manages cases where ints and bools are combined, e.g. 2 and true
  def bool_checker(value)
    return value if value.instance_of? TrueClass or value.instance_of? FalseClass
    return false if value.nil? and value.instance_of? Integer

    true
  end

  def run
    lhs_current = get_data(@lhs)
    rhs_current = get_data(@rhs)
    lhs_value = bool_checker(lhs_current.run)
    rhs_value = bool_checker(rhs_current.run)

    # evaluates the result
    @result = lhs_value.send(@op.to_sym, rhs_value)

    return SproutBool.new(false) if @result == false
    return rhs_current if @op == '&'

    return unless @op == '|'
    return lhs_current if lhs_value != false
    return rhs_current if rhs_value != false
  end
end

class SproutNotNode < Node
  def initialize(obj, frame)
    super()
    @obj = obj
    @op = '!'
    @frame = frame
  end

  def run
    obj_current = get_data(@obj)
    # Every int that equals 0 will return false thus leading to not returning true if object is equal to 0
    return SproutBool.new(true) if @obj == 0

    SproutBool.new(obj_current.send(@op.to_sym))
  end
end

# ===== Assignment =====
class SproutAssign < Node
  attr_reader :name, :value

  def initialize(name, value, frame)
    super()
    @name = name
    @value = value
    @frame = frame
  end

  def correct_frame(frame, key)
    return frame unless frame.find_var(key)

    if frame.vars.key?(key.to_sym)
      frame
    elsif frame != NilClass
      correct_frame(frame.parent, key)
    else
      raise StandardError
    end
  end

  def index_assign
    correct_frame(@frame, @name.data).vars[@name.data.to_sym].assign_index(get_data(@name.index), get_node(@value))
  end

  def run
    if @name.is_a? SproutIndex
      index_assign
    else
      correct_frame(@frame, @name).vars[@name.to_sym] = if @value.instance_of?(String) && @frame.find_var(@value.to_sym)
                                                          @frame.vars[@value.to_sym]
                                                        elsif @value.is_a? Node or @value.is_a? SproutIndex
                                                          @value.run
                                                        else
                                                          @value
                                                        end
    end
  end
end
