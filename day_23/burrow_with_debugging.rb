# frozen_string_literal: true

class Burrow
  ROOM_TYPE = %w[A B C D].freeze
  DOOR_SPACES = [2, 4, 6, 8].freeze
  ENERGY_MULTIPLIER = {
    "A" => 1,
    "B" => 10,
    "C" => 100,
    "D" => 1000
  }.freeze

  attr_reader :rooms, :spaces, :room_spaces
  attr_accessor :energy

  def initialize(rooms, spaces = nil, debug: false)
    @rooms = rooms
    @spaces = spaces || Array.new(11)
    @energy = 0
    @room_spaces = rooms.map { |room| room.count(nil) }
    @debug = debug
  end

  def initialize_dup(other)
    super
    @rooms = other.rooms.map(&:dup)
    @spaces = other.spaces.dup
    @energy = other.energy.dup
    @room_spaces = other.room_spaces.map(&:dup)
  end

  def puts_debug(message)
    return unless @debug

    puts message
  end

  def finished?
    @room_spaces.all?(&:zero?) && ROOM_TYPE.each_with_index.all? { |amphipod, room_index| rooms[room_index].all? { |cell| cell == amphipod } }
  end

  def move(source_type, source_index, target_type, target_index, cost)
    new_burrow = dup
    case source_type
    when :r
      case target_type
      when :r
        new_burrow.move_room_to_room(source_index, target_index)
      when :s
        new_burrow.move_room_to_space(source_index, target_index)
      else
        raise "Invalid move"
      end
    when :s
      new_burrow.move_space_to_room(source_index, target_index)
    else
      raise "Invalid move"
    end
    new_burrow.energy += cost
    new_burrow
  end

  def move_room_to_room(room_index, target_room_index)
    # @energy += room_to_room_cost(room_index, target_room_index)

    # depth1 = rooms[room_index].count(&:nil?)
    # depth2 = rooms[target_room_index].count(&:nil?) - 1
    depth1 = room_spaces[room_index]
    depth2 = room_spaces[target_room_index] - 1
    amphipod = rooms[room_index][depth1]
    rooms[room_index][depth1] = nil
    room_spaces[room_index] += 1
    room_spaces[target_room_index] -= 1
    rooms[target_room_index][depth2] = amphipod
  end

  def room_to_room_cost(room_index, target_room_index)
    # depth1 = rooms[room_index].count(&:nil?)
    # depth2 = rooms[target_room_index].count(&:nil?) - 1
    depth1 = room_spaces[room_index]
    depth2 = room_spaces[target_room_index] - 1
    amphipod = rooms[room_index][depth1]

    space_above_room = (room_index + 1) * 2
    space_above_target_room = (target_room_index + 1) * 2

    room_cost = depth1 + depth2 + 2
    hallway_cost = (space_above_room - space_above_target_room).abs
    cost = (room_cost + hallway_cost) * ENERGY_MULTIPLIER[amphipod]
    # puts_debug "Moving #{amphipod} from room #{room_index} to room #{target_room_index} costing #{cost} energy (#{room_cost} room + #{hallway_cost} hallway * #{ENERGY_MULTIPLIER[amphipod]})"

    cost
  end

  def move_room_to_space(room_index, space_index)
    # @energy += room_to_space_cost(room_index, space_index)

    # depth = rooms[room_index].count(&:nil?)
    depth = room_spaces[room_index]
    amphipod = rooms[room_index][depth]
    rooms[room_index][depth] = nil
    room_spaces[room_index] += 1
    spaces[space_index] = amphipod
  end

  def room_to_space_cost(room_index, space_index)
    # depth = rooms[room_index].count(&:nil?)
    depth = room_spaces[room_index]
    amphipod = rooms[room_index][depth]
    room_cost = depth + 1
    space_above_room = (room_index + 1) * 2
    hallway_cost = (space_index - space_above_room).abs
    cost = (room_cost + hallway_cost) * ENERGY_MULTIPLIER[amphipod]
    # puts_debug "Moving #{amphipod} from room #{room_index + 1} to space #{space_index + 1} costing #{cost} energy (room #{room_cost} + hall #{hallway_cost}) * #{ENERGY_MULTIPLIER[amphipod]}"

    cost
  end

  def move_space_to_room(space_index, room_index)
    #@energy += space_to_room_cost(space_index, room_index)
    # depth = rooms[room_index].count(&:nil?) - 1
    depth = room_spaces[room_index] - 1
    amphipod = spaces[space_index]
    spaces[space_index] = nil
    room_spaces[room_index] -= 1
    rooms[room_index][depth] = amphipod
  end

  def space_to_room_cost(space_index, room_index)
    # depth = rooms[room_index].count(&:nil?) - 1
    depth = room_spaces[room_index] - 1
    amphipod = spaces[space_index]
    room_cost = depth + 1
    space_above_room = (room_index + 1) * 2
    hallway_cost = (space_index - space_above_room).abs
    cost = (room_cost + hallway_cost) * ENERGY_MULTIPLIER[amphipod]
    # puts_debug "Moving #{amphipod} from space #{space_index} to room #{room_index} costing #{cost} energy (room #{room_cost} + hall #{hallway_cost}) * #{ENERGY_MULTIPLIER[amphipod]}"

    cost
  end

  def display
    puts " 0123456789a"
    puts "#############"
    ds = @spaces.map { |space| space.nil? ? "." : space }
    puts "##{ds.join}#"
    tr = @rooms.map { |r| r.map { |c| c.nil? ? "." : c } }.transpose
    puts "####{tr[0].join('#')}###"
    tr[1..].each do |r|
      puts "  ##{r.join('#')}#"
    end
    puts "  #########"
    puts "   0 1 2 3"
    puts
  end

  # def display_spaces
  #   [ds[0, 2], ".", ds[2], ".", ds[3], ".", ds[4], ".", ds[5, 2]].join
  # end

  def valid_moves
    valid_space_to_room_moves + valid_room_to_room_moves + valid_room_to_space_moves
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
    @spaces.each_with_index do |amphipod, space_index|
      next if amphipod.nil?

      target_room_index = ROOM_TYPE.index(amphipod)
      next unless room_can_accept_amphipods?(target_room_index)

      space_above_room = (target_room_index + 1) * 2

      if space_index < space_above_room
        # puts_debug "space #{space_index} to room #{target_room_index} --> moving right"
        space_range_to_check = (space_index + 1)..space_above_room
      else
        # puts_debug "space #{space_index} to room #{target_room_index} --> moving left"
        space_range_to_check = space_above_room..(space_index - 1)
      end

      next unless space_range_to_check.all? { |i| @spaces[i].nil? }
        # puts_debug "Checking spaces #{space_range_to_check} - CLEAR!"
      #else
        # puts_debug "Checking spaces #{space_range_to_check} - BLOCKED!"
        # next
      #end

      # puts_debug "Amphipod #{amphipod} can move from space #{space_index} to room #{target_room_index}"
      valid_moves << [:s, space_index, :r, target_room_index, space_to_room_cost(space_index, target_room_index)]
    end

    valid_moves
  end

  def valid_room_to_room_moves
    valid_moves = []

    tops_of_stacks = rooms.map { |room| room.compact.first }
    tops_of_stacks.each_with_index.each do |amphipod, room_index|
      # skip empty rooms
      next if amphipod.nil?

      # skip if the amphipod at the top of the stack is already in its home
      next if amphipod == ROOM_TYPE[room_index]

      target_room_index = ROOM_TYPE.index(amphipod)

      # skip if the target room is full
      next unless rooms[target_room_index].any?(&:nil?)

      space_above_room = (room_index + 1) * 2
      space_above_target_room = (target_room_index + 1) * 2

      if room_index < target_room_index
        # moving to the right
        # puts_debug "moving right. checking spaces #{space_above_room} to #{space_above_target_room}"
        space_range_to_check = space_above_room..space_above_target_room
      else
        # moving to the left
        # puts_debug "moving left. checking spaces #{space_above_target_room} to #{space_above_room}"
        space_range_to_check = space_above_target_room..space_above_room
      end
      next unless space_range_to_check.all? { |i| spaces[i].nil? }

      # puts_debug "Amphipod #{amphipod} can move from room #{room_index} to room #{target_room_index}"
      valid_moves << [:r, room_index, :r, target_room_index, room_to_room_cost(room_index, target_room_index)]
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
      valid_spaces.reverse_each do |space_index|
        # puts_debug "Amphipod #{amphipod} can move from room #{room_index} to space #{space_index}"
        valid_moves << [:r, room_index, :s, space_index, room_to_space_cost(room_index, space_index)]
      end

      spaces_to_the_right = (space_above_room + 1)..10
      spaces_to_the_right.each do |space_index|
        next if DOOR_SPACES.include?(space_index)
        break unless spaces[space_index].nil?

        # puts_debug "Amphipod #{amphipod} can move from room #{room_index} to space #{space_index}"
        valid_moves << [:r, room_index, :s, space_index, room_to_space_cost(room_index, space_index)]
      end
    end

    valid_moves
  end
end
