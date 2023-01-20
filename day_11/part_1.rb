# frozen_string_literal: true

require "./grid"

input = ARGF.readlines(chomp: true).map { |line| line.chars.map(&:to_i) }

grid = Grid.new(input)

flashes = 0

100.times do
  flashed = []

  grid.increase_energy_levels

  loop do
    grid.each_coord do |y, x|
      next if grid[y, x] <= 9
      next if flashed.include?([y, x])

      flashed << [y, x]

      grid.neighbouring_cells(y, x).each do |ny, nx|
        grid.increment(ny, nx)
      end
    end

    break if (grid.flash_coords - flashed).empty?
  end

  flashed.each do |y, x|
    grid[[y, x]] = 0
  end

  flashes += flashed.size
end

puts flashes
