# frozen_string_literal: true

# Models an Amphipod Burrow
class Burrow
  ROOM_TYPE = %w[A B C D].freeze
  ROOM_INDEX = {
    "A" => 0,
    "B" => 1,
    "C" => 2,
    "D" => 3
  }.freeze
  DOOR_SPACES = [2, 4, 6, 8].freeze
  ENERGY_MULTIPLIER = {
    "A" => 1,
    "B" => 10,
    "C" => 100,
    "D" => 1000
  }.freeze

  attr_reader :rooms, :spaces, :room_spaces
  attr_accessor :energy

  def initialize(rooms, spaces = nil)
    @rooms = rooms
    @spaces = spaces || Array.new(11)
    @energy = 0
    @room_spaces = rooms.map { |room| room.count(nil) }
  end

  def initialize_dup(other)
    super
    @rooms = other.rooms.map(&:dup)
    @spaces = other.spaces.dup
    @energy = other.energy.dup
    @room_spaces = other.room_spaces.map(&:dup)
  end

  def state
    [*rooms.flatten, *spaces]
  end

  def finished?
    @room_spaces.all?(&:zero?) &&
      ROOM_INDEX.all? do |amphipod, room_index|
        rooms[room_index].all?(amphipod)
      end
  end

  def move(type, source_index, target_index)
    new_burrow = dup
    case type
    when :r
      new_burrow.move_room_to_space(source_index, target_index)
    when :s
      new_burrow.move_space_to_room(source_index, target_index)
    end
    new_burrow
  end

  def move_room_to_space(room_index, space_index)
    depth = room_spaces[room_index]
    amphipod = rooms[room_index][depth]
    rooms[room_index][depth] = nil
    room_spaces[room_index] += 1
    spaces[space_index] = amphipod

    room_cost = depth + 1
    space_above_room = (room_index + 1) * 2
    hallway_cost = (space_index - space_above_room).abs
    @energy += (room_cost + hallway_cost) * ENERGY_MULTIPLIER[amphipod]
  end

  def move_space_to_room(space_index, room_index)
    depth = room_spaces[room_index] - 1
    amphipod = spaces[space_index]
    spaces[space_index] = nil
    room_spaces[room_index] -= 1
    rooms[room_index][depth] = amphipod

    room_cost = depth + 1
    space_above_room = (room_index + 1) * 2
    hallway_cost = (space_index - space_above_room).abs
    @energy += (room_cost + hallway_cost) * ENERGY_MULTIPLIER[amphipod]
  end

  def display
    puts "#############"
    ds = @spaces.map { |space| space.nil? ? "." : space }
    puts "##{ds.join}#"
    tr = @rooms.map { |r| r.map { |c| c.nil? ? "." : c } }.transpose
    puts "####{tr[0].join('#')}###"
    tr[1..].each do |r|
      puts "  ##{r.join('#')}#"
    end
    puts "  #########"
    puts
  end

  def valid_moves
    valid_space_to_room_moves + valid_room_to_space_moves
  end

  def room_can_accept_amphipods?(room_index)
    # Room must have at least one empty cell and the other cells must contain the correct amphipods for the room
    rooms[room_index].first.nil? && room_is_valid?(room_index)
  end

  def room_is_valid?(room_index)
    room = rooms[room_index]
    amphipod = ROOM_TYPE[room_index]

    # Room cells must be empty or contain the correct amphipod for the room
    room.all? { |cell| cell.nil? || cell == amphipod }
  end

  def valid_space_to_room_moves
    valid_moves = []

    spaces.each_with_index do |amphipod, space_index|
      next if amphipod.nil?

      target_room_index = ROOM_INDEX[amphipod]
      next unless room_can_accept_amphipods?(target_room_index)

      space_above_room = (target_room_index + 1) * 2

      space_range_to_check = if space_index < space_above_room
                               (space_index + 1)..space_above_room
                             else
                               space_above_room..(space_index - 1)
                             end

      next unless spaces[space_range_to_check].all?(nil)

      valid_moves << [:s, space_index, target_room_index]
    end

    valid_moves
  end

  def valid_room_to_space_moves
    valid_moves = []

    tops_of_stacks = rooms.map { |room| room.compact.first }
    tops_of_stacks.each_with_index.each do |amphipod, room_index|
      # skip empty rooms
      next if amphipod.nil?

      # skip if the amphipod (and its neighbours) are already in the correct column
      next if amphipod == ROOM_TYPE[room_index] && room_is_valid?(room_index)

      space_above_room = (room_index + 1) * 2
      spaces_to_the_left = 0...space_above_room
      valid_spaces = []
      spaces_to_the_left.reverse_each do |space_index|
        next if DOOR_SPACES.include?(space_index)
        break unless spaces[space_index].nil?

        valid_spaces << space_index
      end

      spaces_to_the_right = (space_above_room + 1)..10
      spaces_to_the_right.each do |space_index|
        next if DOOR_SPACES.include?(space_index)
        break unless spaces[space_index].nil?

        valid_spaces << space_index
      end

      valid_spaces.sort_by { |s| (space_above_room - s).abs }.each do |space_index|
        valid_moves << [:r, room_index, space_index]
      end
    end

    valid_moves
  end
end
