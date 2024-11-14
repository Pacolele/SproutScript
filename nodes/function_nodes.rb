#!/usr/bin/env ruby
# frozen_string_literal: true

class SproutFunctions
  def get_data(node)
    current = node
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
end

class SproutPrint < SproutFunctions
  def initialize(string, frame)
    @string = string
    @string = string.to_sym if string.is_a? String
    @frame = frame
  end

  def run
    raise SproutVariableError, @string if @string.is_a? Symbol and !@frame.find_var(@string)

    puts "==> #{get_data(@string)}"
  end
end

# ============ Complex data functions ============

class SproutLength < SproutFunctions
  attr_accessor :string

  def initialize(string, frame)
    throw ValueError unless string.is_a? String or string.is_a? SproutComplexData
    @string = string
    @frame = frame
    @length = 0
  end

  def run
    @length = if @string.is_a? SproutString
                SproutInt.new(@string.list.length)
              elsif @string.is_a? SproutList
                SproutInt.new(@string.value.length)
              else
                SproutInt.new(@frame.get_var(@string).list.length)
              end
    @length
  end
end

class SproutSplit < SproutFunctions
  attr_accessor :splitted

  def initialize(string, delimeter, frame)
    @string = string
    @delimeter = delimeter
    @splitted = []
    @frame = frame
  end

  def run
    @splitted = if @string.is_a? SproutString
                  @string.value.split(@delimeter)
                else
                  @frame.get_var(@string).value.split(@delimeter)
                end

    @splitted.each_with_index do |node, index|
      @splitted[index] = SproutString.new(node)
    end

    SproutList.new(@splitted)
  end
end

class SproutIndex < SproutFunctions
  attr_reader :data, :index

  def initialize(data, index, frame)
    @data = data
    @index = index
    @frame = frame
  end

  def run
    this_index = if @index.is_a? Integer
                   @index
                 elsif @index.is_a? String
                   @frame.get_var(@index)
                 elsif @index.is_a? Node
                   @index.run
                 elsif @index.is_a? SproutMainData
                   @index.run
                 end
    this_index = get_data(this_index) unless this_index.is_a? Integer

    if @data.is_a? SproutString
      @data.list[this_index]
    else
      var = @frame.get_var(@data)
      if var.is_a? SproutSplit
        var.splitted[this_index]
      elsif var.is_a? SproutList
        unless (this_index <= var.list.length - 1) and (this_index >= 0)
          raise SproutIndexOutOfBoundsError, [this_index, var.list.length - 1]
        end

        var.list[this_index]
      end
    end
  end
end

class SproutAppend < SproutFunctions
  def initialize(list, add, frame)
    @list = list
    @add = add
    @frame = frame
  end

  def run
    this_list = if @list.instance_of? String or @list.instance_of? Symbol
                  @frame.get_var(@list)
                else
                  @list
                end
    this_add = if @add.instance_of? String or @add.instance_of? Symbol
                 @frame.get_var(@add).clone
               else
                 @add.clone
               end
    this_list.append(this_add)
  end
end

class SproutPop < SproutFunctions
  attr_accessor :list

  def initialize(list, frame)
    @list = list
    @frame = frame
  end

  def run
    this_list = if @list.instance_of? String or @list.instance_of? Symbol
                  @frame.get_var(@list)
                else
                  @list
                end
    this_list.pop
  end
end

class SproutClear < SproutFunctions
  def initialize(list, frame)
    @list = list
    @frame = frame
  end

  def run
    this_list = if @list.instance_of? String or @list.instance_of? Symbol
                  @frame.get_var(@list)
                else
                  @list
                end
    this_list.clear
  end
end

class SproutSort < SproutFunctions
  def initialize(list, frame)
    @list = list
    @frame = frame
  end

  def run
    this_list = if @list.instance_of? String or @list.instance_of? Symbol
                  @frame.get_var(@list)
                else
                  @list
                end
    this_list.sort
  end
end

class SproutDeleteAt < SproutFunctions
  def initialize(list, index, frame)
    @list = list
    @index = index
    @frame = frame
  end

  def run
    this_list = if @list.instance_of? String or @list.instance_of? Symbol
                  @frame.get_var(@list)
                else
                  @list
                end
    this_list.delete_at(@index.run)
  end
end

class SproutInput < SproutFunctions
  def initialize(msg, frame)
    @msg = msg
    @frame = frame
  end

  def run
    this_msg = get_data(@msg)

    print this_msg
    gets.chomp
  end
end

class SproutWhatIs < SproutFunctions
  def initialize(item, frame)
    @item = item
    @frame = frame
  end

  def run
    if @frame.find_var(@item) and (@item.instance_of? String or @item.instance_of? Symbol)
      @frame.get_var(@item).type
    else
      @item.type
    end
  end
end

class SproutTest < SproutFunctions
  def initialize(lhs, rhs, frame, test_list)
    @lhs = lhs
    @rhs = rhs
    @frame = frame
    @test_list = test_list
  end

  def run
    this_lhs = get_data(@lhs)
    this_rhs = get_data(@rhs)

    @test_list.append([this_lhs, this_rhs])
  end
end
