# frozen_string_literal: true

def sum_of_integers(n)
  (n * (n + 1)) / 2
end

input = ARGF.readline.split(",").map(&:to_i)
median = input.sort[input.size / 2]
f_mean = input.sum.fdiv(input.size)
means = [f_mean.floor, f_mean.ceil]

part_1 = input.sum { |n| (n - median).abs }
puts "Part 1: #{part_1}"

part_2 = means.map do |mean|
  input.sum { |n| sum_of_integers((n - mean).abs) }
end.min
puts "Part 2: #{part_2}"
