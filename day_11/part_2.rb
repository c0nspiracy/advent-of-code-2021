# frozen_string_literal: true

require "./grid"

input = ARGF.readlines(chomp: true).map { |line| line.chars.map(&:to_i) }

grid = Grid.new(input)

step = 1

loop do
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

  break if flashed.size == 100

  step += 1
end

puts step
