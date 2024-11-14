#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../requirements/requirements'

def debug(node)
  puts
  puts '==========================='
  puts "#{node.inspect} created!"
  puts '==========================='
  puts
end

# This file contains classes for basic data types in SproutScript

# ===== Data =====
# To check if any incoming data type is our custom data objects, all objects inherit from this main class
class SproutMainData
  attr_accessor :type
end

# ===== Basic Data =====
# Parent class for all basic data types
class SproutBasicData < SproutMainData
  def initialize
    super()
    # @value = NilClass
    @value = NilClass
  end

  def run
    @value
  end
end

# Custom NilClass to be returned from functions
class SproutNilClass < SproutMainData
  def run
    nil
  end
end

# ===== Variables =====
# Basic variables are stored in a class, more details to come
class SproutVariable < SproutBasicData
  attr_accessor :value
  attr_reader :name, :type

  def initialize(name, value)
    super()
    raise SproutVariableNameError unless name.match(/[a-zA-Z_]*/)

    @name = name
    @value = value
  end

  def run
    @value.run
  end
end

# ===== Integer =====
# Basic integers
class SproutInt < SproutBasicData
  attr_accessor :value

  def initialize(num)
    super()
    throw ValueError unless num.instance_of? Integer
    @value = num
    @type = 'integer'
  end

  def negate
    @value = -@value
    self
  end

  def bool_zero
    return false if @value == 0

    true
  end
end

# ====== Float =======
# Basic float
class SproutFloat < SproutBasicData
  def initialize(float)
    super()
    throw ValueError unless float.instance_of? Float
    @value = float
    @type = 'float'
  end

  def negate
    @value = -@value
    self
  end
end

# Boolean
class SproutBool < SproutBasicData
  def initialize(bool)
    super()
    throw SproutLogicError unless bool.instance_of? TrueClass or bool.instance_of? FalseClass
    @value = bool
    @type = 'boolean'
  end
end

# ========= Complex data ========

# class SproutComplexData < SproutMainData
#   attr_accessor :list, :value
#   def initialize
#     super()
#     @list = []
#     @value = NilClass
#   end
#   def run()
#     @value
#   end
# end

# class SproutString < SproutComplexData
#   def initialize(string)
#     super()
#     throw ValueError unless string.instance_of? String
#     string.split("").each {|c|
#       if c != "\""
#         @list.append(c)
#       end
#       }

#     @value = string.delete_prefix('"').delete_suffix('"')
#     @type = 'string'
#   end
#   def run
#     @list.join('')
#   end
# end

# class SproutList < SproutComplexData
#   def initialize(param)
#     super()
#     puts string
#     @value = string
#     @type = 'list'
#   end

#   def run()

#   end
# end
