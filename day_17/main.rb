# frozen_string_literal: true

input = ARGF.read.chomp.delete_prefix("target area: ")
xrange, yrange = input.split(", ").map do |chunk|
  Range.new(*chunk.split("=").last.split("..").map(&:to_i))
end

# initial_position = [0, 0]
# attempted_velocities = []

# puts x_range
# puts y_range

# def sum_of_ints(n)
#   (n * (n + 1)) / 2
# end
#
# def int_from_sum(sum)
#   0.5 * (Math.sqrt((8 * sum) + 1) - 1)
# end

# def trajectory(sx, sy, dx, dy)
#   initial = [sy, sx, dy, dx]
#   Enumerator.produce(initial) do |previous|
#     y, x, dy, dx = previous
#     pos = [y + dy, x + dx]
#     dx += 0 <=> dx
#     dy -= 1
#     [*pos, dy, dx]
#   end
# end

def triangular(n) = n * (n + 1) / 2
def loc(init_velocity, steps) = steps * ((init_velocity + (init_velocity - steps + 1)) / 2.0)
def possible_x(xrange)
  [*1..xrange.max].filter{|init_x| [*1..init_x].any?{xrange === loc(init_x, _1)}}
end
def target_hit?(init_x, init_y, xrange, yrange)
  (0..999).each do |steps|
    x = steps >= init_x ? triangular(init_x) : loc(init_x, steps)
    y = loc(init_y, steps)
    return true if xrange === x && yrange === y
    return false if xrange.last < x || yrange.first > y # We're past the target - stop checking!
  end
  false
end
if [*1..xrange.min].any?{xrange === triangular(_1)} # I suspect everyone's puzzle input satisfies this, so use the shortcut
  puts triangular(yrange.min)
else
  max_init_y = possible_x(xrange).map{|init_x| [*yrange.min..yrange.min.abs].filter{|init_y| target_hit?(init_x, init_y, xrange, yrange)}.max}.max
  puts triangular(max_init_y)
end

puts possible_x(xrange).sum{|init_x| [*yrange.min..yrange.min.abs]
  .filter{|init_y| target_hit?(init_x, init_y, xrange, yrange)}.count}



# start_x = int_from_sum(x_range.begin).ceil
# end_x = int_from_sum(x_range.end).floor
# top_of_arc = sum_of_ints()

# binding.irb
