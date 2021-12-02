# frozen_string_literal: true

position = 0
depth = 0
aim = 0
input = File.readlines("input", chomp: true)

input.each do |line|
  direction, amount = line.split
  amount = amount.to_i

  case direction
  when "forward"
    position += amount
    depth += aim * amount
  when "down"
    aim += amount
  when "up"
    aim -= amount
  end
end

puts position * depth
