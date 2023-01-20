# frozen_string_literal: true

polymer, _, *raw_rules = ARGF.readlines(chomp: true)

rules = {}
raw_rules.map do |rule|
  from, to = rule.split(" -> ")
  rules[from.chars] = to
end

10.times do
  new_polymer = polymer.chars.each_cons(2).flat_map do |a, b|
    [a, rules[[a, b]]]
  end
  new_polymer << polymer[-1]

  polymer = new_polymer.join
end

puts polymer.chars.tally.values.minmax.reverse.reduce(:-)
