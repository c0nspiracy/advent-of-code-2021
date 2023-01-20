# frozen_string_literal: true

def display(grid)
  puts
  puts grid.map { |line| line.map { |cell| cell ? "#" : "." }.join }.join("\n")
end

input = ARGF.readlines(chomp: true)
paper, folds = input.slice_before(&:empty?).to_a
dots = paper.map { |line| line.split(",").map(&:to_i) }
folds.reject!(&:empty?).map! do |fold|
  d, n = fold[/[xy]=\d+/].split("=")
  [d, n.to_i]
end

max_x = dots.max_by(&:first).first + 1
max_y = dots.max_by(&:last).last + 1
grid = Array.new(max_y) { Array.new(max_x, false) }
dots.each { |x, y| grid[y][x] = true }

folds.each_with_index do |(d, n), i|
  grid = grid.transpose if d == "x"

  h1 = grid.slice(0, n)
  h2 = grid.slice(n..).reverse

  grid = h1.each_index.map do |y|
    h1[y].each_index.map do |x|
      h1[y][x] | h2[y][x]
    end
  end

  grid = grid.transpose if d == "x"

  puts "Dots visible after first fold: #{grid.flatten.count(true)}" if i.zero?
end

display(grid)
