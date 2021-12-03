# frozen_string_literal: true

input = File.readlines("input", chomp: true).map(&:chars)

def calculate_rating(input, criteria)
  numbers = input.dup
  numbers.first.size.times do |position|
    column = numbers.transpose[position]
    bit = column.tally.send(criteria, &:reverse).first
    numbers.select! { |row| row[position] == bit }

    return numbers.first.join.to_i(2) if numbers.size == 1
  end
end

oxygen_generator_rating = calculate_rating(input, :max_by)
co2_scrubber_rating = calculate_rating(input, :min_by)

puts oxygen_generator_rating * co2_scrubber_rating
