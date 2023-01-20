# frozen_string_literal: true

# Models a leaf node
class Leaf
  attr_accessor :number

  def initialize(number)
    @number = number
  end

  def leaf?
    true
  end

  def split
    half = number.fdiv(2)
    [half.floor, half.ceil]
  end

  def magnitude
    number
  end

  def pair_to_explode
    nil
  end

  def leaves_in_order(_search)
    self
  end

  def to_s
    number.to_s
  end
  alias inspect to_s
end
