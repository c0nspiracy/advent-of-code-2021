# frozen_string_literal: true

class ALU
  attr_accessor :w, :x, :y, :z

  def initialize(instructions)
    @instructions = instructions
  end

  def execute(input)
    reset

    @instructions.each do |op, a, b|
      av = send(a)
      bv = %w[w x y z].include?(b) ? send(b) : b.to_i

      result = case op
               when "inp"
                 input.shift.to_i
               when "add"
                 av + bv
               when "mul"
                 av * bv
               when "div"
                 av / bv
               when "mod"
                 av % bv
               when "eql"
                 av == bv ? 1 : 0
               end
      send("#{a}=", result)
    end

    # [@w, @x, @y, @z]
    @z
  end

  private

  def reset
    @w = 0
    @x = 0
    @y = 0
    @z = 0
  end
end

input = ARGF.readlines(chomp: true).map(&:split)
alu = ALU.new(input)

#n = 44444439731538
n = 13579246899999
loop do
  res = alu.execute(n.to_s.chars)
  break if res.zero?

  puts "#{n} --> #{res}"
  n -= 1
  n -= 1 while n.to_s.include?("0")
end
