# frozen_string_literal: true

# Models a 5x5 Bingo Board
class BingoBoard
  def self.parse(lines)
    rows = lines.map { |line| line.split.map(&:to_i) }
    new(rows)
  end

  def initialize(rows)
    @board = rows.map do |row|
      row.map { |number| [number, false] }
    end
  end

  def mark(number)
    @board.each do |row|
      row.each_with_index do |(n, _), i|
        row[i][1] = true if n == number
      end
    end
  end

  def win?
    winning_row? || winning_column?
  end

  def sum_of_unmarked_numbers
    @board.flatten(1).sum { |n, b| b ? 0 : n }
  end

  private

  def winning_row?
    @board.any? { |row| row.map(&:last).all? }
  end

  def winning_column?
    @board.transpose.any? { |row| row.map(&:last).all? }
  end
end
