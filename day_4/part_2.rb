# frozen_string_literal: true

require "active_support"
require "active_support/core_ext/object/blank"

require "./bingo_board"

numbers = ARGF.readline.split(",").map(&:to_i)
boards = ARGF.readlines(chomp: true).reject(&:blank?).each_slice(5).map do |board|
  BingoBoard.parse(board)
end

numbers.each do |n|
  boards.each { |b| b.mark(n) }

  if boards.size > 1
    boards.delete_if(&:win?)
  elsif boards.first.win?
    puts "Score: #{n * boards.first.sum_of_unmarked_numbers}"
    break
  end
end
