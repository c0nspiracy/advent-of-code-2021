# frozen_string_literal: true

class Lanternfish
  attr_reader :timer

  def initialize(timer)
    @timer = timer
  end

  def tick
    @timer -= 1
    return unless @timer.negative?

    @timer = 6
    Lanternfish.new(8)
  end
end

input = ARGF.readline.split(",").map(&:to_i)
school = input.map { |n| Lanternfish.new(n) }

80.times do
  school.concat(school.map(&:tick).compact)
end

puts school.size
