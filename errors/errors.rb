#!/usr/bin/env ruby
# frozen_string_literal: true

# This file contains custom error messages raised by SproutScript
require 'io/console'

class SproutError < StandardError
  def initialize(msg)
    divider
    super(msg)
  end

  def divider
    puts '*-' * (IO.console.winsize[1] / 2)
  end
end

# ===== Variable naming error =====
class SproutVariableNameError < SproutError
  def initialize(name)
    super('ERROR: This variable name is invalid!')
    puts "\t#{name} is not a valid name for your variable. You may only use letters between A-Z, as well as underscores."
    divider
    exit
  end
end

# ===== File not found =====
class SproutFileNotFoundError < SproutError
  def initialize(name)
    super('ERROR: This file cannot be found!')
    puts "The file #{name} cannot be found at the specified location. Double check the name of the file!"
    divider
    exit
  end
end

# ===== Wrong file suffix =====
class SproutSuffixError < SproutError
  def initialize(name)
    super('ERROR: This is not a valid SproutScript-file!')
    puts "The file #{name} does not appear to be a valid SproutScript-file. Your file must have the file extension '.sps' in order to be used."
    name = name.split('.')
    name = "#{name[0]}.sps"
    puts "Please rename your file to #{name} and try again!"
    divider
    exit
  end
end

# ===== Uninitialized variable =====
class SproutVariableError < SproutError
  def initialize(name)
    super('ERROR: This variable could not be found!')
    puts "The variable '#{name}' does not exist in any reachable scope."
    puts 'Verify that the variable name is spelled correctly, and that it can be reached in the current scope.'
    divider
    exit
  end
end

# ===== Invalid CLI arguments =====
class SproutArgumentError < SproutError
  def initialize
    super('ERROR: Incorrect command line argument!')
    puts 'You have entered command line arguments not supported by SproutScript. Only the following command line arguments are supported: '
    puts '--log ==> Prints debug and log info for the parser'
    divider
    exit
  end
end

class SproutLengthError < SproutError
  def initialize
    super('ERROR: Incorrect data type in parameter!')
    puts "ERROR: Incorrect data type in parameter!\n"
    puts "You have entered a wrong data type into the parameter of length() expected String or List\n"
    divider
    exit
  end
end

class SproutMethodError < SproutError
  def initialize(method)
    super('ERROR: Incorrect use of method in command line!')
    puts "\tERROR: Incorrect use of method in command line!\n"
    puts "\tYou have entered method #{method} in a wrong way, try double checking if you've entered the correct parameters to the function."
    get_error(method)
    divider
    exit
  end

  def get_error(method)
    if method == 'append'
      puts "\t- Expected: append(LIST, DATA)"
      puts "\t- LIST on the format [DATA, DATA, DATA]"
      puts "\t- DATA such as String, Integer, Boolean, Float"
    elsif method == 'pop'
      puts "\t- Expected: pop(LIST, INTEGER)"
      puts "\t- LIST on the format [DATA, DATA, DATA]"
      puts "\t- INTEGER >= 1"
    elsif method == 'split'
      puts "\t- Expected: Split(STRING, DELIMETER)"
      puts "\t- STRING on the format \"Example text\""
      puts "\t- DELIMETER should be entered within '' and should be any type of characters"
    elsif method == 'length'
      puts "\t- Expected: length(LIST), length(STRING), length(VAR)"
      puts "\t- LIST on the format [DATA, DATA, DATA]"
      puts "\t- STRING on the format \"Example text\""
      puts "\t- VAR should be in the format LIST or STRING"
    elsif method == 'clear'
      puts "\t- Expected: clear(LIST)"
      puts "\t- LIST on the format [DATA, DATA, DATA]"
      puts "\t- DATA such as String, Integer, Boolean, Float"
    else
      puts "\t- Method not found you entered"
    end
  end
end

# ===== else if without else =====
class SproutElseError < SproutError
  def initialize(_syntax)
    super("ERROR: 'else if' or 'else' statement found without matching 'if'-statement!")
    puts 'An else if or else statement was detected without a matching if-statement first.'
    puts 'These statements can only be used after an if-statement before it.'
    divider
    exit
  end
end

# ===== Break outside of loop =====
class SproutBreakError < SproutError
  def initialize
    super("ERROR: 'break' found outside of loop!")
    puts 'A "break" statement was detected, but not in a loop!'
    puts 'The "break"-keyword is used to break a for- or while-loop.'
    puts 'The offending instance of the keyword was not detected to be inside a loop.'
    divider
    exit
  end
end

# ===== Wrong operator with string =====
class SproutStringOperatorError < SproutError
  def initialize
    super('ERROR: Invalid operator with string!')
    puts 'SproutScript encoutered an invalid operation for a string.'
    puts 'You may only use the following operators with strings:'
    puts "\t+ (to concatenate strings)"
    puts "\t* (to repeat a string)"
    divider
    exit
  end
end

# ===== Incorrect Data Type =====
class SproutDataTypeError < SproutError
  def initialize(_type)
    super('ERROR: Incorrect data type!')
    puts 'You have entered an incorrect data type into the function.'
    divider
    exit
  end
end

# ===== Index out of bounds =====
class SproutIndexOutOfBoundsError < SproutError
  def initialize(data)
    super('ERROR: Index is out of bounds!')
    puts "You attempted to access index #{data[0]} of a list containing only #{data[1]} items."
    puts 'This operation is not possible!'
    divider
    exit
  end
end

# ===== Return outside of function =====
class SproutReturnError < SproutError
  def initialize
    super('ERROR: Return found outside of function body!')
    puts "The keyword 'return' was found outside of a function definition."
    puts 'This keyword can only be used inside of a function to allow it to send back a value when called.'
    puts 'Please check your code for a misplaced return.'
    divider
    exit
  end
end
