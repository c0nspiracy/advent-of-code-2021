# frozen_string_literal: true

template, _, *raw_rules = ARGF.readlines(chomp: true)

polymer = Hash.new(0)
template.chars.each_cons(2) do |pair|
  polymer[pair.join] += 1
end

rules = {}
raw_rules.map do |rule|
  from, to = rule.split(" -> ")
  rules[from] = ["#{from[0]}#{to}", "#{to}#{from[1]}"]
end

40.times do
  changes = Hash.new(0)

  polymer.each do |pair, count|
    changes[pair] -= count
    rules[pair].each do |new_pair|
      changes[new_pair] += count
    end
  end

  changes.each { |k, v| polymer[k] += v }
end

letter_counts = Hash.new(0)
polymer.each do |pair, count|
  pair.chars.each do |char|
    letter_counts[char] += count
  end
end

letter_counts.transform_values! { |v| v.fdiv(2).round }
puts letter_counts.values.minmax.reverse.inject(:-)
