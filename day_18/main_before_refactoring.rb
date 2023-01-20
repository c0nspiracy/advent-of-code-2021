# frozen_string_literal: true

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
    puts "after addition: #{pair.to_s}"
    pair.reduce
    pair
  end

  def magnitude
    (3 * left.magnitude) + (2 * right.magnitude)
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
        memo << [self, :left, left]
      else
        memo.concat left.leaves_with_pairs
      end
      if right.leaf?
        memo << [self, :right, right]
      else
        memo.concat right.leaves_with_pairs
      end
    end
  end

  def leaves_in_order(search = nil)
    if search == self
      [].tap do |memo|
        memo.concat left.leaves_in_order(search) unless left.leaf?
        memo << self
        memo.concat right.leaves_in_order(search) unless right.leaf?
      end
    else
      [
        *left.leaves_in_order(search),
        *right.leaves_in_order(search)
      ]
    end
  end

  def root
    parent ? parent.root : self
  end

  def leaf?
    false
  end

  def reduce
    loop do
      action_taken = false
      if p = find_leftmost(4)
        puts "Exploding #{p}"
        p.explode
        action_taken = "explode: "
      elsif a = find_leftmost_number
        p, d, n = a
        np = n.split
        np.parent = p
        if d == :left
          p.left = np
        else
          p.right = np
        end
        action_taken = "split:   "
      end

      break unless action_taken
      puts "after #{action_taken} #{to_s}"
    end
  end

  def find_leftmost(search_depth)
    return self if depth == search_depth

    found = nil
    if left.is_a?(Pair)
      found = left.find_leftmost(search_depth)
    end
    if !found && right.is_a?(Pair)
      found = right.find_leftmost(search_depth)
    end
    found
  end

  def find_leftmost_number
    root.leaves_with_pairs.find { |p,d,n| n.number >= 10 }
  end

  def explode
    leaves = root.leaves_in_order(self)
    first_left = find_nearest_number_left(leaves)
    first_right = find_nearest_number_right(leaves)
    first_left.number += left.number if first_left
    first_right.number += right.number if first_right
    parent.left = RegularNumber.new(0) if left_of_parent?
    parent.right = RegularNumber.new(0) if right_of_parent?
  end

  def find_nearest_number_left(leaves)
    pos = leaves.index(self)
    leaves[0...pos].last
  end

  def find_nearest_number_right(leaves)
    pos = leaves.index(self)
    leaves[pos + 1..].first
  end

  def depth
    @parent ? @parent.depth + 1 : 0
  end

  def self.from_array(a)
    l, r = a
    left = l.is_a?(Array) ? from_array(l) : RegularNumber.new(l)
    right = r.is_a?(Array) ? from_array(r) : RegularNumber.new(r)
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

class RegularNumber
  attr_accessor :number

  def initialize(number)
    @number = number
  end

  def leaf?
    true
  end

  def split
    half = number.fdiv(2)
    Pair.from_array([half.floor, half.ceil])
  end

  def magnitude
    number
  end

  def leaves_in_order(_search)
    self
  end

  def to_s
    number.to_s
  end
  alias inspect to_s
end

input = ARGF.readlines(chomp: true).map { |line| Pair.from_array(eval(line)) }
result = input.reduce(:+)
puts result
puts result.magnitude
