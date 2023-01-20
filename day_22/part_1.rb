# frozen_string_literal: true

input = ARGF.readlines(chomp: true)

cubes = {}
input.each do |line|
  md = line.match(/\A(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)\z/)
  captures = md.captures
  state = captures.shift
  x1, x2, y1, y2, z1, z2 = captures.map(&:to_i)

  next if x1 < -50 || x2 > 50 || y1 < -50 || y2 > 50 || z1 < -50 || z2 > 50

  x1.upto(x2) do |x|
    y1.upto(y2) do |y|
      z1.upto(z2) do |z|
        cubes[[z, y, x]] = state == "on" ? 1 : 0
      end
    end
  end
end

puts cubes.values.count(1)
