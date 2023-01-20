# frozen_string_literal: true

class MatrixGrid
  def initialize(matrix)
    @matrix = matrix
  end

  def top_left
    [0, 0]
  end

  def bottom_right
    @bottom_right ||= [row_count - 1, column_count - 1]
  end

  def neighbours(coord)
    y, x = coord
    [].tap do |neighbours|
      neighbours << [y - 1, x] unless y.zero?
      neighbours << [y, x - 1] unless x.zero?
      neighbours << [y, x + 1] if x < max_x
      neighbours << [y + 1, x] if y < max_y
    end
  end

  private

  def max_x
    @max_x ||= column_count - 1
  end

  def max_y
    @max_y ||= row_count - 1
  end

  def respond_to_missing?(name, include_private = false)
    @matrix.respond_to?(name, include_private)
  end

  def method_missing(method, *args, &block)
    @matrix.send(method, *args, &block)
  end
end
