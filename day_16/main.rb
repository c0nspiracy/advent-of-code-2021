# frozen_string_literal: true

require "./packet_parser"

hex_input = ARGF.read.chomp
input = hex_input.chars.flat_map { |char| format("%04b", char.to_i(16)).chars }
parser = PacketParser.new(input)

result = parser.parse
puts "Part 1: #{parser.version_sum}"
puts "Part 2: #{result}"
