# frozen_string_literal: true

def intersection(cube_1, cube_2)
  pairs = cube_1.zip(cube_2)
  cube = [-pairs[0][1], pairs[1].max, pairs[2].min, pairs[3].max, pairs[4].min, pairs[5].max, pairs[6].min]
  cube[1] > cube[2] || cube[3] > cube[4] || cube[5] > cube[6] ? nil : cube
end

input = ARGF.readlines(chomp: true)

cubes = input.map do |line|
  md = line.match(/\A(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)\z/)
  captures = md.captures
  state = captures.shift == "on" ? 1 : 0

  [state, *captures.map(&:to_i)]
end

processed = []
cubes.each do |cube|
  to_add = processed.filter_map { |other| intersection(cube, other) }
  processed << cube if cube[0] == 1
  processed.concat(to_add)
end

answer = processed.sum { |c| c[0] * (c[2] - c[1] + 1) * (c[4] - c[3] + 1) * (c[6] - c[5] + 1) }
puts answer
