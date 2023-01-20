class Grid
  def initialize(grid)
    @grid = grid
  end

  def each_coord
    @grid.each_with_index do |row, y|
      row.each_index do |x|
        yield(y, x)
      end
    end
  end

  def [](y, x)
    @grid[y][x]
  end

  def neighbours(y_coord, x_coord)
    neighbours = []
    neighbours << [y_coord - 1, x_coord] if y_coord.positive?
    neighbours << [y_coord, x_coord - 1] if x_coord.positive?
    neighbours << [y_coord, x_coord + 1] if x_coord < max_x
    neighbours << [y_coord + 1, x_coord] if y_coord < max_y
    neighbours
  end

  def max_y
    @max_y ||= @grid.size - 1
  end

  def max_x
    @max_x ||= @grid.first.size - 1
  end
end
