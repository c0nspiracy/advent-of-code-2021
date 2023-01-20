# frozen_string_literal: true

require "./grid"

input = ARGF.readlines(chomp: true).map { |line| line.chars.map(&:to_i) }

grid = Grid.new(input)
low_points = {}

grid.each_coord do |y, x|
  neighbours = grid.neighbouring_values(y, x)
  height = input[y][x]
  low_points[[y, x]] = height if neighbours.all? { |n| height < n }
end

puts "Part 1: #{low_points.values.sum(&:succ)}"

basin_sizes = low_points.keys.map do |ly, lx|
  visited = []
  basin_size = 0
  search_coords = [[ly, lx]]

  loop do
    discovered = []

    search_coords.each do |cy, cx|
      grid.each_neighbour(cy, cx) do |coords, value|
        next if visited.include?(coords)

        visited << coords
        discovered << coords if value < 9
      end
    end

    basin_size += discovered.size
    search_coords = discovered

    break if search_coords.empty?
  end

  basin_size
end

puts "Part 2: #{basin_sizes.max(3).reduce(:*)}"
