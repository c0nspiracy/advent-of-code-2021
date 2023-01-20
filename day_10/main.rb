# frozen_string_literal: true

BRACKETS = {
  "(" => ")",
  "[" => "]",
  "{" => "}",
  "<" => ">"
}.freeze

SYNTAX_ERROR_SCORE = {
  ")" => 3,
  "]" => 57,
  "}" => 1197,
  ">" => 25_137
}.freeze

input = ARGF.readlines(chomp: true).map(&:chars)

syntax_error_score = 0
autocomplete_scores = input.filter_map do |line|
  stack = []

  line.each do |bracket|
    if BRACKETS.keys.include?(bracket)
      stack << bracket
    elsif stack.pop != BRACKETS.key(bracket)
      syntax_error_score += SYNTAX_ERROR_SCORE[bracket]
      stack = []
      break
    end
  end

  next if stack.empty?

  stack.reverse.inject(0) do |score, char|
    (score * 5) + BRACKETS.keys.index(char) + 1
  end
end

puts "Part 1: #{syntax_error_score}"

middle_score = autocomplete_scores.sort[autocomplete_scores.size / 2]
puts "Part 2: #{middle_score}"
