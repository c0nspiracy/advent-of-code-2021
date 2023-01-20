# frozen_string_literal: true

require "./grid"

def dijkstra(grid, source_y, source_x)
  q = []
  dist = {}
  prev = {}

  grid.each_coord do |y, x|
    dist[[y, x]] = Float::INFINITY
    prev[[y, x]] = nil
    q << [y, x]
  end
  dist[[source_y, source_x]] = 0

  loop do
    break if q.empty?

    uy, ux = q.min_by { |y, x| dist[[y, x]] }

    q.delete([uy, ux])
    break if uy == grid.max_y && ux == grid.max_x

    grid.neighbours(uy, ux).each do |vy, vx|
      next unless q.include?([vy, vx])

      alt = dist[[uy, ux]] + grid[vy, vx]
      if alt < dist[[vy, vx]]
        dist[[vy, vx]] = alt
        prev[[vy, vx]] = [uy, ux]
      end
    end
  end

  [dist, prev]
end

input = ARGF.readlines(chomp: true).map { |line| line.chars.map(&:to_i) }

grid = Grid.new(input)

dist, prev = dijkstra(grid, 0, 0)

s = []
uy = grid.max_y
ux = grid.max_x
if prev[[uy, ux]]
  loop do
    break if uy.nil? && ux.nil?

    s.unshift [uy, ux]
    uy, ux = prev[[uy, ux]]
  end
end

puts (s.sum { |y, x| grid[y, x] } - grid[0, 0])
