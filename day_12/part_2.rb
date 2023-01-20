# frozen_string_literal: true

class Cave
  attr_reader :connections

  def initialize(name)
    @name = name
    @connections = []
  end

  def add_connection(cave)
    @connections << cave
  end
end

def paths_to_end_from(caves, path_so_far, cave, depth=0)
  next_path = path_so_far + [cave]
  puts "#{"  " * depth} CAVE #{cave} (#{next_path.join('->')})"
  if cave == "end"
    puts "#{"  " * depth} REACHED THE END!"
    return [next_path.dup]
  end

  all_connections = caves[cave].connections
  small_caves = all_connections.select { |cave| cave =~ /^[a-z]+$/ }
  small_cave_visits = next_path.tally.select { |k, _| k =~ /^[a-z]+$/ && k != "start" }
  puts "small cave visits: #{small_cave_visits}"
  small_cave_visited_twice = small_cave_visits.any? { |_, v| v > 1 }

  connections = all_connections.reject do |cave|
    cave == "start" || (
      small_caves.include?(cave) && small_cave_visits.key?(cave) && small_cave_visits[cave] >= (small_cave_visited_twice ? 1 : 2)
    )
  end

  puts "#{"  " * depth} Connections from here: #{connections} (already visited #{all_connections - connections})"

  if connections.empty?
    puts "#{"  " * depth} DEAD END!"
    []
  else
    connections.flat_map do |next_cave|
      puts "#{"  " * depth} BRANCHING TO #{next_cave}"
      paths_to_end_from(caves, next_path.dup, next_cave, depth + 1)
    end
  end
end

input = ARGF.readlines(chomp: true).map { |line| line.split("-") }
puts input.inspect

caves = {}

# build caves
input.flatten.uniq.each do |cave|
  caves[cave] = Cave.new(cave)
end

# connect caves
input.each do |cave_left, cave_right|
  caves[cave_left].add_connection(cave_right)
  caves[cave_right].add_connection(cave_left)
end

puts paths_to_end_from(caves, [], "start").count
