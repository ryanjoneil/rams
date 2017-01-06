# Fixnums can be added to expressions or variables or multiplied
# by them to create expressions:
#
#     4 - (3 * x)
#     y / 2
class Fixnum
  alias old_add +
  alias old_sub -
  alias old_multiply *
  alias old_divide /

  def +(other)
    return other + self if other.is_a? RAMS::Expression
    old_add other
  end

  def -(other)
    return -other + self if other.is_a? RAMS::Expression
    old_sub other
  end

  def *(other)
    return other * self if other.is_a? RAMS::Expression
    old_multiply other
  end

  def /(other)
    return other * (1.0 / self) if other.is_a? RAMS::Expression
    old_divide other
  end
end

# Floats can be treated the same way as Fixnums.
class Float
  alias old_add +
  alias old_sub -
  alias old_multiply *
  alias old_divide /

  def +(other)
    return other + self if other.is_a? RAMS::Expression
    old_add other
  end

  def -(other)
    return -other + self if other.is_a? RAMS::Expression
    old_sub other
  end

  def *(other)
    return other * self if other.is_a? RAMS::Expression
    old_multiply other
  end

  def /(other)
    return other * (1.0 / self) if other.is_a? RAMS::Expression
    old_divide other
  end
end
