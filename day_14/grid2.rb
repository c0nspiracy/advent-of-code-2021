# frozen_string_literal: true

# Models a 2D grid
class Grid
  def initialize(grid)
    @grid = grid
  end

  def each_neighbour(y_coord, x_coord)
    neighbouring_cells(y_coord, x_coord).each do |y, x|
      yield(y, x, @grid[y][x])
    end
  end

  def neighbouring_values(y_coord, x_coord)
    neighbouring_cells(y_coord, x_coord).each do |y, x|
      @grid[y][x]
    end
  end

  def neighbouring_cells(y_coord, x_coord)
    neighbours = []
    neighbours << [y_coord - 1, x_coord] if y_coord.positive?
    neighbours << [y_coord, x_coord - 1] if x_coord.positive?
    neighbours << [y_coord, x_coord + 1] if x_coord < max_x
    neighbours << [y_coord + 1, x_coord] if y_coord < max_y
    neighbours
  end

  def each_coord
    @grid.each_with_index do |row, y|
      row.each_index do |x|
        yield(y, x)
      end
    end
  end

  private

  def max_y
    @max_y ||= @grid.size - 1
  end

  def max_x
    @max_x ||= @grid.first.size - 1
  end
end
