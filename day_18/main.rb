# frozen_string_literal: true

require "json"
require "./pair"

input = ARGF.readlines(chomp: true)#.map { |line| Pair.from_array(JSON.parse(line)) }

#puts input.dup.reduce(:+).magnitude

perms = input.permutation(2).map do |a, b|
  p = Pair.from_array(JSON.parse(a)) + Pair.from_array(JSON.parse(b))
  p.magnitude
end

puts perms.max
