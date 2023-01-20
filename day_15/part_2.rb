# frozen_string_literal: true

require "./matrix_grid"
require "rubygems"
require "algorithms"
require "matrix"

def dijkstra(grid, source)
  q = Containers::PriorityQueue.new { |x, y| (x <=> y) == -1 }
  visited = {}
  dist = Hash.new(Float::INFINITY)
  prev = {}

  dist[source] = 0
  q.push(source, 0)

  until q.empty?
    u = q.pop
    visited[u] = true
    break if u == grid.bottom_right

    grid.neighbours(u).each do |v|
      next if visited[v]

      alt = dist[u] + grid[*v]
      next if alt >= dist[v]

      dist[v] = alt
      prev[v] = u
      q.push(v, alt)
    end
  end

  prev
end

def scale(matrix)
  matrices = [matrix]

  0.upto(7).each do |n|
    matrices << matrix.map { |v| ((v + n) % 9) + 1 }
  end

  Matrix.vstack(*matrices.each_cons(5).map { |row| Matrix.hstack(*row) })
end

input = ARGF.readlines(chomp: true).map { |line| line.chars.map(&:to_i) }
matrix = Matrix.rows(input)
matrix = scale(matrix)
grid = MatrixGrid.new(matrix)
prev = dijkstra(grid, grid.top_left)

shortest_path = 0
pos = grid.bottom_right
until pos == grid.top_left
  shortest_path += grid[*pos]
  pos = prev[pos]
end
puts shortest_path
