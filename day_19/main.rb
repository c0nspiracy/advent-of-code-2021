# frozen_string_literal: true

require "matrix"
require "set"

class Scanner
  attr_accessor :location, :rotation, :beacons, :distances, :distance_beacon_map

  def initialize(beacons)
    @location = nil
    @rotation = nil
    @beacons = beacons
    @distances = []
    @distance_beacon_map = {}
  end
end

def distance(a, b)
  Math.sqrt(a.zip(b).map { |c, d| (c - d)**2 }.sum)
end

def generate_rotations
  r1 = Matrix[[0, 0, -1], [0, 1, 0], [1, 0, 0]]
  r2 = Matrix[[1, 0, 0], [0, 0, -1], [0, 1, 0]]
  r3 = Matrix[[0, -1, 0], [1, 0, 0], [0, 0, 1]]

  result = [0, 1, 2, 3].repeated_permutation(3).map do |x, y, z|
    (r1**x) * (r2**y) * (r3**z)
  end

  result.uniq
end

def scanner_location(beacon_pair1, beacon_pair2)
  loc1 = beacon_pair1[0] - beacon_pair2[0]
  loc2 = beacon_pair1[1] - beacon_pair2[1]
  return loc1 if loc1 == loc2

  loc1 = beacon_pair1[0] - beacon_pair2[1]
  loc2 = beacon_pair1[1] - beacon_pair2[0]
  return loc1 if loc1 == loc2

  nil
end

scanners = {}

input = ARGF.readlines(chomp: true).slice_after(&:empty?)
input.each do |scanner_input|
  scanner_id, *coord_input = scanner_input.reject(&:empty?)
  n = scanner_id[/\d+/].to_i
  coords = coord_input.map { |line| Vector[*line.split(",").map(&:to_i)] }
  scanners[n] = Scanner.new(coords)
  coords.combination(2).each do |a, b|
    d = distance(a, b)
    scanners[n].distance_beacon_map[d] = [a, b]
    scanners[n].distances << d
  end
end

scanners[0].location = Vector.zero(3)
scanners[0].rotation = Matrix.identity(3)

overlaps = {}
scanners.keys.combination(2).each do |i, j|
  common_distances = (scanners[i].distances & scanners[j].distances)
  overlaps[[i, j]] = common_distances if common_distances.size >= 12
end

rotations = generate_rotations
result = Set[*scanners[0].beacons]
scanners_processed = 1

loop do
  break if scanners_processed == scanners.length

  overlaps.each do |(i, j), dist|
    next unless [scanners[i].location, scanners[j].location].one?

    i, j = j, i if scanners[i].location.nil?

    s1_pair = scanners[i].distance_beacon_map[dist[0]]
    s2_pair = scanners[j].distance_beacon_map[dist[0]]

    rotate1 = s1_pair.map { |v| scanners[i].rotation * v }

    rotations.each do |r|
      rotate2 = s2_pair.map { |v| r * v }
      location = scanner_location(rotate1, rotate2)
      next if location.nil?

      location += scanners[i].location
      scanners[j].location = location
      scanners[j].rotation = r

      result.merge(scanners[j].beacons.map { |beacon| (r * beacon) + location })

      scanners_processed += 1
      break
    end
  end
end

puts "Part 1: #{result.count}"

md = scanners.keys.combination(2).map do |i, j|
  (scanners[i].location - scanners[j].location).map(&:abs).sum
end
puts "Part 2: #{md.max}"
