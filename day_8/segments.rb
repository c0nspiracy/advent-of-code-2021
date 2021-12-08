# frozen_string_literal: true

# Models the wiring of a seven segment display
class Segments
  DIGITS = {
    0 => "abcefg",
    1 => "cf",
    2 => "acdeg",
    3 => "acdfg",
    4 => "bcdf",
    5 => "abdfg",
    6 => "abdefg",
    7 => "acf",
    8 => "abcdefg",
    9 => "abcdfg"
  }.invert.freeze

  RULES = {
    2 => [:-, %w[a b d e g]], # Rule out segments missing from 1
    3 => [:-, %w[b d e g]],   # Rule out segments missing from 7
    4 => [:-, %w[a e g]],     # Rule out segments missing from 4
    5 => [:&, %w[a d g]],     # Narrow down segments common to 2, 3, 5
    6 => [:&, %w[a b f g]],   # Narrow down segments common to 0, 6, 9
    7 => [:&, []]             # No-op because all segments are active for 8
  }.freeze

  def initialize
    # Start out with all wiring possibilities
    range = ("a".."g").to_a
    @segments = range.product([range]).to_h
  end

  def <<(wires)
    method, segments = RULES[wires.size]

    segments.each do |segment|
      @segments[segment] = @segments[segment].send(method, wires)
    end

    clean_up_wiring
  end

  def [](wires)
    DIGITS[wires.map(&mapping).sort.join]
  end

  private

  def clean_up_wiring
    mutually_exclusive_wires.each do |wires_to_remove|
      @segments.transform_values! do |wires|
        wires_to_remove == wires ? wires : wires - wires_to_remove
      end
    end
  end

  def mutually_exclusive_wires
    @segments.values.tally.select { |wires, count| wires.size == count }.keys
  end

  def mapping
    @mapping ||= @segments.invert.transform_keys(&:first)
  end
end
