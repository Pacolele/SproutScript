require_relative '../requirements/requirements'
require 'test/unit'

class TestNodes < Test::Unit::TestCase
  def setup
    @global = Frame.new(NilClass)
  end

  def arit(lhs, op, rhs, frame)
    return SproutArithmetic.new(lhs,op,rhs,frame)
  end

  def assign(var, value, frame)
    temp = SproutAssign.new(var, value, frame)
    return temp
  end

  def comp(lhs, op, rhs, frame)
    return SproutComparison.new(lhs,op,rhs,frame)
  end

  def logic(lhs, op, rhs, frame)
    return SproutLogicNode.new(lhs,op,rhs,frame)
  end

  def not(value, frame)
    return SproutNotNode.new(value, frame)
  end

  def int(num)
    return SproutInt.new(num)
  end

  def test_assignment
    setup()
    a1 = assign("a1", SproutInt.new(10), @global)
    a2 = assign("a2", a1, @global)
    assert_equal(10, a1.get_data(a1))
    assert_equal(10, a2.get_data(a2))
    assert_equal(a1.get_data(a1), a2.get_data(a1))

    a3 = assign("a3", arit(a1, '+', a2, @global), @global)
    assert_equal(20, a3.get_data(a3))

    a4 = assign("a4", arit(int(20), '+', int(5), @global), @global)
    assert_equal(25, a4.get_data(a4))
    a5 = assign("a5", arit(a4, '*', int(5), @global), @global)
    assert_equal(125, a5.get_data(a5))

    a6 = assign("a6", arit(arit(int(4), '*', int(3),@global ), '/', int(2), @global), @global)
    assert_equal(6, a6.get_data(a6))

    a7 = assign("a7", arit(a6, '*', a6, @global), @global)
    assert_equal(36, a7.get_data(a7))

  end


end




# class TestBooleans < Test::Unit::TestCase
#   def setup
#     @global = Frame.new
#   end

#   def test_comparision
#     setup()


#   end

#   def test_logic

#   end

# end


