# frozen_string_literal: true

input = ARGF.readlines(chomp: true).map do |line|
  line.split(" -> ").map { |segment| segment.split(",").map(&:to_i) }
end

floor = Hash.new { |h, k| h[k] = 0 }

input.each do |(x1, y1), (x2, y2)|
  if x1 == x2
    y1, y2 = [y1, y2].sort
    y1.upto(y2) { |y| floor[[x1, y]] += 1 }
  elsif y1 == y2
    x1, x2 = [x1, x2].sort
    x1.upto(x2) { |x| floor[[x, y1]] += 1 }
  end
end

overlapping_points = floor.count { |_, v| v > 1 }
puts overlapping_points
