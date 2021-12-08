# frozen_string_literal: true

require "./segments"

input = ARGF.readlines(chomp: true)
entries = input.map do |line|
  line.split(" | ").map { |chunks| chunks.split.map(&:chars) }
end

answer = entries.sum do |signals, outputs|
  segments = Segments.new
  signals.sort_by(&:size).each { |wires| segments << wires }
  outputs.map { |wires| segments[wires] }.join.to_i
end

puts answer
