# frozen_string_literal: true

require "./burrow"

input = ARGF.readlines(chomp: true).map { |line| line.scan(/[\w.]/) }.reject(&:empty?)

# Part 2
input.insert(2, %w[D C B A], %w[D B A C])

spaces = input.shift
rooms = input.map { |row| row.map { |c| c == "." ? nil : c } }.transpose
burrow = Burrow.new(rooms, spaces.map { |s| s == "." ? nil : s })

class Descender
  attr_reader :lowest_energy

  def initialize
    @lowest_energy = Float::MAX - 1
    @cache = Hash.new { |h, k| h[k] = Float::MAX }
  end

  def descend(burrow)
    moves = burrow.valid_moves.sort
    return [] if moves.empty?
    if @cache[burrow.state] < burrow.energy
      puts "(1) Seen this state at lower energy"
      return []
    end

    moves.filter_map do |cost, *move|
      next if burrow.energy + cost >= @lowest_energy

      new_burrow = burrow.move(cost, *move)

      # if we have already seen this state at lower energy then don't process any more moves from this point?
      if @cache[new_burrow.state] <= new_burrow.energy
        puts "(2) Seen this state #{new_burrow.state} at lower energy #{@cache[new_burrow.state]} <= #{new_burrow.energy}"
        next#return []
      end

      @cache[new_burrow.state] = new_burrow.energy

      res = new_burrow.finished? ? [new_burrow.energy] : descend(new_burrow)
      @lowest_energy = [@lowest_energy, res.min].compact.min
      res
    end.flatten
  end
end

d = Descender.new
d.descend(burrow)
puts d.lowest_energy
