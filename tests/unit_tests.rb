require 'test/unit'
require_relative '../requirements/requirements'

# ========================================================
# Comprehensive test suite for all nodes in SproutScript
# ========================================================

# Tests basic data types
class TestSproutData < Test::Unit::TestCase
  def setup
    @frame = Frame.new(NilClass)
    @syntax_tree = SyntaxTree.new(NilClass)
    @sprout_int = SproutInt.new(3)
    @sprout_float = SproutFloat.new(3.5)
    @sprout_string = SproutString.new('Hello')
    @sprout_list = SproutList.new([SproutInt.new(1), SproutInt.new(2), SproutInt.new(3)])
  end

  # tests functions to find and get variables
  def test_frame
    @frame.set_var('var1', @sprout_int)
    assert_equal(@frame.get_var('var1'), @sprout_int)
    assert_equal(@frame.find_var('var1'), true)
    assert_equal(@frame.find_var('var2'), false)
  end

  # verifies that syntax trees cannot go back when they have no parents
  def test_syntax_tree
    assert_raise(StandardError) { @syntax_tree.back }
  end

  # tests basic ints with negation
  def test_sprout_int
    @sprout_int.negate
    assert_equal(@sprout_int.run, -3)
  end

  # tests basic floats with negation
  def test_sprout_float
    @sprout_float.negate
    assert_equal(@sprout_float.run, -3.5)
  end

  # verifies functionality of strings
  def test_sprout_string
    assert_equal(@sprout_string.run, 'Hello')
  end

  # verifies functionality of lists
  # specific list nodes will be tested later
  def test_sprout_list
    assert_equal(@sprout_list.run, [1, 2, 3])
    @sprout_list.append(SproutInt.new(4))
    assert_equal(@sprout_list.run, [1, 2, 3, 4])
    @sprout_list.pop
    assert_equal(@sprout_list.run, [1, 2, 3])
  end
end

# Tests arithmetic noes
class TestSproutArithmetic < Test::Unit::TestCase
  def setup
    @frame = Frame.new(NilClass)
  end

  # simple arithmetic tests
  def test_simple_arithmetic_operations
    addition = SproutArithmetic.new(SproutInt.new(2), '+', SproutInt.new(3), @frame)
    subtraction = SproutArithmetic.new(SproutInt.new(7), '-', SproutInt.new(2), @frame)
    multiplication = SproutArithmetic.new(SproutInt.new(4), '*', SproutInt.new(3), @frame)
    division = SproutArithmetic.new(SproutInt.new(10), '/', SproutInt.new(2), @frame)

    assert_equal(5, addition.run.run)
    assert_equal(5, subtraction.run.run)
    assert_equal(12, multiplication.run.run)
    assert_equal(5, division.run.run)
  end

  # tests nested arithmetic nodes
  def test_nested_arithmetic_operations
    nested_add_sub = SproutArithmetic.new(SproutArithmetic.new(SproutInt.new(10), '+', SproutInt.new(5), @frame), '-',
                                          SproutInt.new(3), @frame)
    nested_mul_div = SproutArithmetic.new(SproutArithmetic.new(SproutInt.new(4), '*', SproutInt.new(3), @frame), '/',
                                          SproutInt.new(2), @frame)

    assert_equal(12, nested_add_sub.run.run)
    assert_equal(6, nested_mul_div.run.run)
  end

  # tests arithmetic operations with strings
  def test_string_operations
    string_concat = SproutArithmetic.new(SproutString.new('Hello'), '+', SproutString.new(' World'), @frame)
    string_repeat = SproutArithmetic.new(SproutString.new('abc'), '*', SproutInt.new(3), @frame)

    assert_equal('Hello World', string_concat.run.run)
    assert_equal('abcabcabc', string_repeat.run.run)
  end

  # nested arithmetics with floats
  def test_float_operations
    addition = SproutArithmetic.new(SproutFloat.new(2.2), '+', SproutFloat.new(3.3), @frame)
    subtraction = SproutArithmetic.new(SproutFloat.new(7.7), '-', SproutFloat.new(2.2), @frame)
    multiplication = SproutArithmetic.new(SproutFloat.new(4.4), '*', SproutFloat.new(3.3), @frame)
    division = SproutArithmetic.new(SproutFloat.new(10.0), '/', SproutFloat.new(2.0), @frame)

    assert_in_delta(5.5, addition.run.run, 0.01)
    assert_in_delta(5.5, subtraction.run.run, 0.01)
    assert_in_delta(14.52, multiplication.run.run, 0.01)
    assert_in_delta(5.0, division.run.run, 0.01)
  end
end

# Tests comparison nodes
class TestSproutComparison < Test::Unit::TestCase
  def setup
    @frame = Frame.new(NilClass)
  end

  # simple tests of comparison nodes
  def test_simple_comparison_operations
    greater = SproutComparison.new(SproutInt.new(5), '>', SproutInt.new(3), @frame)
    less = SproutComparison.new(SproutInt.new(2), '<', SproutInt.new(7), @frame)
    equal = SproutComparison.new(SproutInt.new(4), '==', SproutInt.new(4), @frame)

    assert_equal(true, greater.run.run)
    assert_equal(true, less.run.run)
    assert_equal(true, equal.run.run)
  end
end

# Tests logic nodes
class TestSproutLogicNode < Test::Unit::TestCase
  def setup
    @frame = Frame.new(NilClass)
  end

  # Logic nodes with nested comparisons - usual case
  def test_simple_logical_operations
    and_node = SproutLogicNode.new(SproutComparison.new(SproutInt.new(5), '>', SproutInt.new(3), @frame), '&',
                                   SproutComparison.new(SproutInt.new(2), '<', SproutInt.new(7), @frame), @frame)
    or_node = SproutLogicNode.new(SproutComparison.new(SproutInt.new(5), '<', SproutInt.new(3), @frame), '|',
                                  SproutComparison.new(SproutInt.new(2), '>', SproutInt.new(7), @frame), @frame)
    not_node = SproutNotNode.new(SproutBool.new(false), @frame)

    assert_equal(true, and_node.run.run)
    assert_equal(false, or_node.run.run)
    assert_equal(true, not_node.run.run)
  end
end

# Some tests to verify the functionality of assignment nodes
class TestSproutAssign < Test::Unit::TestCase
  def setup
    @frame = Frame.new(NilClass)
  end

  # assigmnent wit arithmetic operators
  def test_assign_and_arithmetic_operations
    assign_node = SproutAssign.new('x', SproutInt.new(3), @frame)
    assign_node.run
    arithmetic_node_assignment = SproutAssign.new('y', SproutArithmetic.new('x', '+', SproutInt.new(2), @frame), @frame)

    # assigning node with arithmetic operand
    arithmetic_node_assignment.run
    assert_equal(5, @frame.get_var('y').run)

    # basic reassignment of variable
    reassign_node = SproutAssign.new('x', SproutInt.new(10), @frame)
    reassign_node.run
    assert_equal(10, @frame.get_var('x').run)
  end
end

# Tests if-nodes
class TestSproutIfNode < Test::Unit::TestCase
  def setup
    @frame = Frame.new(NilClass)
  end

  # basic test, the variable x is assigned the value 3 if the comparison is true
  def test_simple_if_node
    if_node = SproutIfNode.new(SproutComparison.new(SproutInt.new(5), '>', SproutInt.new(3), @frame), @frame,
                               SyntaxTree.new(NilClass))
    if_node.syntax_tree.append(SproutAssign.new('x', SproutInt.new(3), @frame))
    if_node.run
    assert_equal(3, @frame.get_var('x').run)
  end

  # chains if, else if and else to trigger the else and set y to 10
  def test_complex_if_node
    if_node = SproutIfNode.new(SproutComparison.new(SproutInt.new(5), '<', SproutInt.new(3), @frame), @frame,
                               SyntaxTree.new(NilClass))
    else_if_node = SproutIfNode.new(SproutComparison.new(SproutInt.new(5), '==', SproutInt.new(3), @frame), @frame,
                                    SyntaxTree.new(NilClass))
    else_node = SproutIfNode.new(true, @frame,
                                 SyntaxTree.new(NilClass))
    if_node.append_statement(else_if_node)
    if_node.append_statement(else_node)
    else_node.syntax_tree.append(SproutAssign.new('y', SproutInt.new(10), @frame))

    if_node.run
    assert_equal(10, @frame.get_var('y').run)
  end
end

# Tests for-loops functionality by incrementing y for each loop
class TestSproutFor < Test::Unit::TestCase
  def setup
    @frame = Frame.new(NilClass)
  end

  def test_simple_for_loop
    assign_node = SproutAssign.new('x', SproutInt.new(0), @frame)
    condition = SproutComparison.new('x', '<', SproutInt.new(5), @frame)
    increment = SproutArithmetic.new('x', '+', SproutInt.new(1), @frame)
    syntax = SyntaxTree.new(NilClass)
    syntax.tree.append(SproutAssign.new('y', increment, @frame))

    for_node = SproutFor.new(assign_node, condition, increment, @frame, syntax)
    for_node.run
    assert_equal(5, @frame.get_var('y').run)
  end
end

# Tests do-while loop
class TestSproutDoWhile < Test::Unit::TestCase
  def setup
    @frame = Frame.new(NilClass)
  end

  def test_simple_do_while_loop
    assign_node = SproutAssign.new('x', SproutInt.new(0), @frame)
    condition = SproutComparison.new('x', '<', SproutInt.new(5), @frame)
    increment = SproutArithmetic.new('x', '+', SproutInt.new(1), @frame)
    syntax = SyntaxTree.new(NilClass)
    syntax.tree.append(SproutAssign.new('x', increment, @frame))

    assign_node.run
    do_while_node = SproutDoWhile.new(condition, @frame, syntax)
    do_while_node.run
    assert_equal(5, @frame.get_var('x').run)
  end
end

# Tests while-loop
class TestSproutWhile < Test::Unit::TestCase
  def setup
    @frame = Frame.new(NilClass)
  end

  def test_simple_while_loop
    assign_node = SproutAssign.new('x', SproutInt.new(0), @frame)
    condition = SproutComparison.new('x', '<', SproutInt.new(5), @frame)
    increment = SproutArithmetic.new('x', '+', SproutInt.new(1), @frame)
    syntax = SyntaxTree.new(NilClass)
    syntax.tree.append(SproutAssign.new('x', increment, @frame))

    assign_node.run
    while_node = SproutWhile.new(condition, @frame, syntax)
    while_node.run
    assert_equal(5, @frame.get_var('x').run)
  end
end

# Tests break
class TestSproutBreak < Test::Unit::TestCase
  def setup
    @frame = Frame.new(NilClass)
  end

  # sets up a loop and breaks is prematurely
  def test_break_in_loop
    assign_node = SproutAssign.new('x', SproutInt.new(0), @frame)
    condition = SproutComparison.new('x', '<', SproutInt.new(5), @frame)
    increment = SproutArithmetic.new('x', '+', SproutInt.new(1), @frame)
    syntax = SyntaxTree.new(NilClass)
    syntax.tree.append(SproutAssign.new('x', increment, @frame))
    syntax.tree.append(SproutBreak.new(@frame))

    assign_node.run
    while_node = SproutWhile.new(condition, @frame, syntax)
    while_node.run
    assert_equal(1, @frame.get_var('x').run)
  end
end

class TestSproutUserFunction < Test::Unit::TestCase
  def setup
    @frame = Frame.new(NilClass)
  end

  def test_function_with_no_parameters_and_return
    syntax = SyntaxTree.new(NilClass)
    syntax.tree.append(SproutReturn.new(SproutInt.new(5), @frame))

    user_func_1 = SproutUserFunction.new(@frame, syntax)
    assert_equal(5, user_func_1.run.run)
  end

  def test_function_with_parameters_and_return
    syntax = SyntaxTree.new(NilClass)
    syntax.tree.append(SproutAssign.new('x', 'y', @frame))
    syntax.tree.append(SproutReturn.new('x', @frame))

    user_func_2 = SproutUserFunction.new(@frame, syntax, ['y'])
    assert_equal(7, user_func_2.run([SproutInt.new(7)]).run)
  end
end

class TestSproutFunctionCall < Test::Unit::TestCase
  def setup
    @frame = Frame.new(NilClass)
  end

  def test_function_call
    syntax = SyntaxTree.new(NilClass)
    syntax.tree.append(SproutReturn.new('x', @frame))

    @frame.functions[:test_func] = SproutUserFunction.new(@frame, syntax, ['x'])

    func_call = SproutFunctionCall.new('test_func', [SproutInt.new(5)], @frame)
    assert_equal(5, func_call.run.run)
  end
end

# Tests user functions
class TestSproutFunctions < Test::Unit::TestCase
  def setup
    @frame = Frame.new(NilClass)
  end

  def test_functions
    @frame.vars[:my_list] =
      SproutList.new([SproutString.new('apple'), SproutString.new('banana'), SproutString.new('cherry')])

    length_node = SproutLength.new('my_list', @frame)
    assert_equal(3, length_node.run.run)

    index_node = SproutIndex.new('my_list', SproutInt.new(1), @frame)
    assert_equal('banana', index_node.run.run)

    append_node = SproutAppend.new('my_list', SproutString.new('date'), @frame)
    append_node.run
    array = @frame.vars[:my_list].run
    assert_equal('date', array.last)

    pop_node = SproutPop.new('my_list', @frame)
    popped_item = pop_node.run.run
    assert_equal('date', popped_item)

    sort_node = SproutSort.new('my_list', @frame)
    sort_node.run
    assert_equal(%w[apple banana cherry], @frame.vars[:my_list].run)

    delete_at_node = SproutDeleteAt.new('my_list', SproutInt.new(1), @frame)
    delete_at_node.run
    assert_equal(%w[apple cherry], @frame.vars[:my_list].run)

    clear_node = SproutClear.new('my_list', @frame)
    clear_node.run
    assert_equal([], @frame.vars[:my_list].run)

    what_is_node = SproutWhatIs.new('my_list', @frame)
    assert_equal('list', what_is_node.run)
  end
end
