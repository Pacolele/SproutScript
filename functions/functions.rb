#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../requirements/requirements'

class SproutUserFunction
  attr_accessor :frame

  def initialize(frame, syntax, param = [])
    @frame = frame
    @syntax = syntax.tree.clone
    @return = SproutNilClass.new
    @param = param
  end

  def run(arguments = [])
    raise StandardError unless @param.length == arguments.length

    if @param != [] and arguments != []
      arguments.each_with_index do |e, i|
        @frame.vars[@param[i].to_sym] = if e.instance_of?(String)
                                          @frame.get_var(e)
                                        elsif e.is_a? Node
                                          e.run
                                        elsif e.is_a? SproutMainData
                                          e
                                        end
      end
    end

    @frame_parent = @frame.parent
    @frame.functions = @frame.parent.functions unless @frame.parent == NilClass
    @frame.parent = NilClass

    @syntax.each do |node|
      return node.run if node.is_a? SproutReturn

      control = node.run
      @return = control.run if control.is_a? SproutReturn
      break unless @return.is_a? SproutNilClass
    end
    @frame.parent = @frame_parent
    @return
  end
end

class SproutReturn
  def initialize(value, frame)
    @value = value
    @frame = frame
  end

  def run
    this_value = @value.clone
    return @frame.get_var(this_value) if this_value.is_a? String
    return this_value.run if this_value.is_a? Node

    this_value
  end
end

class SproutFunctionCall
  def initialize(name, param, frame)
    @name = name.to_sym
    @frame = frame
    @param = param
  end

  def find_global_frame(frame)
    if frame.parent.instance_of?(Frame)
      find_global_frame(frame.parent)
    else
      frame
    end
  end

  def run
    this_frame = find_global_frame(@frame)
    raise StandardError unless this_frame.functions.key?(@name)

    saved = this_frame.functions[@name].clone

    result = saved.run(@param)
    return result.run if result.is_a? Node

    result
  end
end
