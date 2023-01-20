# frozen_string_literal: true

require "./leaf"

# Models a binary tree
class Pair
  def initialize(left, right, parent = nil)
    @left = left
    @right = right
    @parent = parent
  end

  attr_accessor :left, :right, :parent

  def +(other)
    pair = Pair.new(self, other)
    @parent = pair
    other.parent = pair
    puts "after addition: #{pair}"
    pair.reduce
    pair
  end

  def magnitude
    (3 * left.magnitude) + (2 * right.magnitude)
  end

  def reduce
    true while maybe_explode || maybe_split
  end

  def maybe_explode
    pair = pair_to_explode
    return false unless pair

    pair.explode
    puts "after explode: #{self}"
    true
  end

  def maybe_split
    found = number_to_split
    return false unless found

    split(found)
    puts "after split:   #{self}"
    true
  end

  def split(found)
    pair, method, number = found
    new_pair = Pair.from_array(number.split)
    new_pair.parent = pair
    pair.send(method, new_pair)
  end

  def leaf?
    false
  end

  def explode
    left_number, right_number = nearest_numbers
    left_number.number += left.number if left_number
    right_number.number += right.number if right_number
    clear
  end

  def clear
    parent.left = Leaf.new(0) if left_of_parent?
    parent.right = Leaf.new(0) if right_of_parent?
  end

  def root
    parent ? parent.root : self
  end

  def left_of_parent?
    return false unless parent

    parent.left == self
  end

  def right_of_parent?
    return false unless parent

    parent.right == self
  end

  def leaves_with_pairs
    [].tap do |memo|
      if left.leaf?
        memo << [self, :left=, left]
      else
        memo.concat left.leaves_with_pairs
      end
      if right.leaf?
        memo << [self, :right=, right]
      else
        memo.concat right.leaves_with_pairs
      end
    end
  end

  def leaves_in_order(search)
    return leaves_in_order_self if search == self

    [*left.leaves_in_order(search), *right.leaves_in_order(search)]
  end

  def leaves_in_order_self
    [].tap do |memo|
      memo.concat left.leaves_in_order(self) unless left.leaf?
      memo << self
      memo.concat right.leaves_in_order(self) unless right.leaf?
    end
  end

  def pair_to_explode
    return self if depth == 4

    left.pair_to_explode || right.pair_to_explode
  end

  def number_to_split
    root.leaves_with_pairs.find { |_, _, n| n.number >= 10 }
  end

  def nearest_numbers
    leaves = root.leaves_in_order(self)
    position = leaves.index(self)
    left = leaves[position - 1] if position.positive?
    right = leaves[position + 1]
    [left, right]
  end

  def depth
    @parent ? @parent.depth + 1 : 0
  end

  def self.from_array(array)
    l, r = array
    left = l.is_a?(Array) ? from_array(l) : Leaf.new(l)
    right = r.is_a?(Array) ? from_array(r) : Leaf.new(r)
    p = new(left, right)
    left.parent = p if left.is_a?(Pair)
    right.parent = p if right.is_a?(Pair)
    p
  end

  def to_s
    "[#{@left},#{@right}]"
  end

  def inspect
    "<Pair depth=#{depth} [#{@left.inspect}, #{@right.inspect}]>"
  end
end
