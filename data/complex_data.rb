#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../requirements/requirements'

class SproutComplexData < SproutMainData
  attr_accessor :list, :value

  def initialize
    super()
    @list = []
    @value = NilClass
  end

  def run
    @value
  end
end

class SproutString < SproutComplexData
  def initialize(string)
    super()
    throw ValueError unless string.instance_of? String
    string.split('').each do |c|
      @list.append(c) if c != '"'
    end

    @value = string.delete_prefix('"').delete_suffix('"')
    @type = 'string'
  end

  def run
    @list.join('')
  end
end

class SproutList < SproutComplexData
  def initialize(param)
    super()
    param.each do |e|
      @list.append(e)
    end

    @value = param
    @type = 'list'
  end

  def append(new)
    @list.append(new)
    self
  end

  def pop
    @list.pop
  end

  def clear
    @list.clear
    self
  end

  def sort
    @list.sort_by! { |i| i.value }
    self
  end

  def delete_at(index)
    @list.delete_at(index)
  end

  def assign_index(index, assign)
    @list[index] = assign.clone
  end

  def get_list(var)
    res = []
    var.value.each do |e|
      res.append(e.run)
    end
    res
  end

  def run
    finished_list = []
    @list.each do |node|
      finished_list.append(node.run)
    end
    finished_list
  end
end
