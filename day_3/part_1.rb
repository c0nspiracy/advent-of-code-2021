# frozen_string_literal: true

input = File.readlines("input", chomp: true).map(&:chars)

gamma, epsilon = input
  .transpose
  .map { |column| column.tally.minmax_by(&:last).map(&:first) }
  .transpose.map { |number| number.join.to_i(2) }

puts gamma * epsilon
