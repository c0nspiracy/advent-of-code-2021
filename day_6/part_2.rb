# frozen_string_literal: true

input = ARGF.readline.split(",").map(&:to_i)
buckets = Array.new(9) { |n| [n, 0] }.to_h.merge(input.tally)

256.times do
  buckets.transform_keys!(&:pred)
  spawn = buckets.delete(-1)
  buckets[6] += spawn
  buckets[8] = spawn
end

puts buckets.values.sum
