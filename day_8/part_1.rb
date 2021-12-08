# frozen_string_literal: true

input = ARGF.readlines(chomp: true)

answer = input.sum do |line|
  _, output = line.split(" | ")
  output.split.count { |v| [2, 3, 4, 7].include?(v.length) }
end

puts answer
