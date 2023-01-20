# frozen_string_literal: true

DELTAS = [
  [-1, -1], [-1, 0], [-1, 1],
  [0, -1], [0, 0], [0, 1],
  [1, -1], [1, 0], [1, 1]
].freeze

def lit_pixels(image)
  image.values.count(1)
end

def enhance(image, algo)
  new_image = Hash.new(0)
  min_y, max_y = image.keys.minmax_by(&:first).map(&:first)
  min_x, max_x = image.keys.minmax_by(&:last).map(&:last)
  (min_y - 2).upto(max_y + 2) do |y|
    (min_x - 2).upto(max_x + 2) do |x|
      decimal = DELTAS.map { |dy, dx| image[[y + dy, x + dx]] }.join.to_i(2)
      new_image[[y, x]] = algo[decimal].to_i
    end
  end
  new_image
end

def display(image)
  min_y, max_y = image.keys.minmax_by(&:first).map(&:first)
  min_x, max_x = image.keys.minmax_by(&:last).map(&:last)
  (min_y - 1).upto(max_y + 1) do |y|
    puts (min_x - 1).upto(max_x + 1).map { |x| image[[y, x]] == 0 ? "." : "#" }.join
  end
end


algo, input_image = ARGF.readlines(chomp: true).chunk { |line| !line.empty? || nil }.map(&:last)
algo = algo.join.tr(".#", "01")

image = Hash.new(0)
input_image.each_with_index do |row, y|
  row.tr(".#", "01").chars.each_with_index do |char, x|
    image[[y, x]] = char.to_i
  end
end

50.times do |n|
  image = enhance(image, algo)
  image.default = n.odd? ? 0 : 1
  puts "Part 1: #{lit_pixels(image)}" if n == 1
end
puts "Part 2: #{lit_pixels(image)}"
