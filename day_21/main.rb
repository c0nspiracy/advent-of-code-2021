# frozen_string_literal: true

class Player
  attr_reader :player, :position, :score

  def initialize(player, starting_position)
    @player = player
    @position = starting_position
    @score = 0
  end

  def move(spaces)
    @position = ((position + spaces - 1) % 10) + 1
    @score += position
  end

  def won?
    score >= 1000
  end
end

class DeterministicDie
  attr_reader :rolls

  def initialize
    @die = (1..100).to_a.cycle
    @rolls = 0
  end

  def roll
    @rolls += 1
    @die.next
  end
end

players = ARGF.readlines(chomp: true).map do |line|
  Player.new(*line.match(/Player (\d+) starting position: (\d+)/) { |matchdata| matchdata.captures.map(&:to_i) })
end
player_iterator = players.cycle
die = DeterministicDie.new

loop do
  break if players.any?(&:won?)

  player = player_iterator.next
  rolls = 3.times.map { die.roll }
  player.move(rolls.sum)
  puts "Player #{player.player} rolls #{rolls.join('+')} and moves to space #{player.position} for a total score of #{player.score}."
end

losing_player = players.reject(&:won?).first
puts "Part 1: #{losing_player.score * die.rolls}"
