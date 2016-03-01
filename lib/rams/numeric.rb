# TODO
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

# TODO
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
