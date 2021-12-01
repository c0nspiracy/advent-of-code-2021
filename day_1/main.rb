# frozen_string_literal: true

measurements = File.readlines("input", chomp: true).map(&:to_i)

part_1 = measurements.each_cons(2).count { _1 < _2 }
puts "Part 1: #{part_1}"

window_sums = measurements.each_cons(3).map(&:sum)
part_2 = window_sums.each_cons(2).count { _1 < _2 }
puts "Part 2: #{part_2}"
