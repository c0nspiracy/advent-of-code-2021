# frozen_string_literal: true

class PacketParser
  OPERATOR = {
    0 => :sum,
    2 => :min,
    3 => :max,
    5 => :>,
    6 => :<,
    7 => :==
  }.freeze

  def initialize(packet)
    @packet = packet
    @version_sum = 0
  end

  attr_reader :version_sum

  def parse
    @version_sum += next_int(3)
    type_id = next_int(3)

    if type_id == 4
      parse_literal_packet
    else
      parse_operator_packet(type_id)
    end
  end

  private

  def parse_literal_packet
    value = []

    loop do
      prefix = next_int
      value.concat @packet.shift(4)

      break if prefix.zero?
    end

    value.join.to_i(2)
  end

  def parse_operator_packet(type_id)
    length_type_id = next_int

    values = case length_type_id
             when 0 then parse_sub_packets_by_length
             when 1 then parse_sub_packets_by_count
             end

    process_operator(type_id, values)
  end

  def parse_sub_packets_by_length
    sub_packet_length = next_int(15)

    starting_size = @packet.size
    [].tap do |values|
      values << parse until starting_size - @packet.size == sub_packet_length
    end
  end

  def parse_sub_packets_by_count
    next_int(11).times.map { parse }
  end

  def process_operator(type_id, values)
    case type_id
    when 1 then values.reduce(:*)
    when 0, 2, 3 then values.send(OPERATOR[type_id])
    when 5, 6, 7 then compare(OPERATOR[type_id], values)
    end
  end

  def compare(operator, values)
    values[0].send(operator, values[1]) ? 1 : 0
  end

  def next_int(amount = 1)
    @packet.shift(amount).join.to_i(2)
  end
end
