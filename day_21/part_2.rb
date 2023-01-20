# frozen_string_literal: true

starting_positions = ARGF.readlines(chomp: true).map do |line|
  line.scan(/\d+/)[1].to_i
end

$cache = {}
def get_score(*args)
  $cache[args] ||= evolve(*args)
end

def evolve(p1_pos, p2_pos, p1_score, p2_score, die)
  p1_pos = ((p1_pos + die - 1) % 10) + 1
  p1_score += p1_pos
  return [1, 0] if p1_score >= 21

  p1_wins = 0
  p2_wins = 0
  [[3, 1], [4, 3], [5, 6], [6, 7], [7, 6], [8, 3], [9, 1]].each do |roll, freq|
    w2, w1 = get_score(p2_pos, p1_pos, p2_score, p1_score, roll)
    p1_wins += (w1 * freq)
    p2_wins += (w2 * freq)
  end

  [p1_wins, p2_wins]
end

puts evolve(starting_positions[1], starting_positions[0], -starting_positions[1], 0, 0).max
