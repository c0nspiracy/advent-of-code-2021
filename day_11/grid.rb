# frozen_string_literal: true

# Models a 2D grid
class Grid
  def initialize(grid)
    @grid = grid
  end

  def to_s
    @grid.map do |row|
      row.map { |cell| cell > 9 ? "*" : cell }.join
    end.join("\n") << "\n\n"
  end

  def increase_energy_levels
    each_coord do |y, x|
      @grid[y][x] += 1
    end
  end

  def flash_coords
    each_coord.to_a.select { |y, x| @grid[y][x] > 9 }
  end

  def increment(y, x)
    @grid[y][x] += 1
  end

  def [](y, x)
    @grid[y][x]
  end

  def []=((y, x), value)
    @grid[y][x] = value
  end

  def neighbouring_values(y_coord, x_coord)
    neighbouring_cells(y_coord, x_coord).map do |y, x|
      @grid[y][x]
    end
  end

  def neighbouring_cells(y_coord, x_coord)
    neighbours = []

    if y_coord.positive?
      neighbours << [y_coord - 1, x_coord]
      neighbours << [y_coord - 1, x_coord - 1] if x_coord.positive?
      neighbours << [y_coord - 1, x_coord + 1] if x_coord < max_x
    end

    neighbours << [y_coord, x_coord - 1] if x_coord.positive?
    neighbours << [y_coord, x_coord + 1] if x_coord < max_x

    if y_coord < max_y
      neighbours << [y_coord + 1, x_coord]
      neighbours << [y_coord + 1, x_coord - 1] if x_coord.positive?
      neighbours << [y_coord + 1, x_coord + 1] if x_coord < max_x
    end

    neighbours
  end

  def each_coord
    return to_enum(:each_coord) unless block_given?

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
