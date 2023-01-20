# frozen_string_literal: true

class InstructionParser
  attr_reader :instructions, :alus

  TARGET = {
    "w" => 0,
    "x" => 1,
    "y" => 2,
    "z" => 3
  }.freeze

  def initialize(instructions)
    @instructions = parse(instructions)
    @alus = [ALU.new]
  end

  def execute
    inp_idx = 0
    instructions.each_with_index do |(op, a, b), ins_idx|
      puts "Processing instruction #{ins_idx + 1} of #{instructions.length}"
      if op == "inp"
        inp_idx += 1
        new_alus = []
        indices = {}
        alus.each do |alu|
          1.upto(9) do |v|
            new_alu = alu.dup
            new_alu.apply_inp(a, v)
            new_alu.min = (new_alu.min * 10 + v)
            new_alu.max = (new_alu.max * 10 + v)
            if (idx = indices[new_alu.mem.dup])
              new_alus[idx].min = [new_alus[idx].min, new_alu.min].min
              new_alus[idx].max = [new_alus[idx].max, new_alu.max].max
            else
              indices[new_alu.mem.dup] = new_alus.size
              new_alus.push(new_alu)
            end
          end
        end
        @alus = new_alus
        puts "Processing #{alus.size} ALU states"
      else
        alus.each do |alu|
          alu.apply_op(op, a, b)
        end
      end
    end
  end

  private

  def parse(instructions)
    instructions.map do |op, a, b|
      target = TARGET[a]
      if op == "inp"
        [op, target]
      else
        if %w[w x y z].include?(b)
          ["mem#{op}", target, TARGET[b]]
        else
          [op, target, b.to_i]
        end
      end
    end
  end
end


class ALU
  attr_reader :mem
  attr_accessor :min, :max

  def initialize
    @mem = [0, 0, 0, 0]
    @min = 0
    @max = 0
  end

  def initialize_copy(original)
    @mem = original.mem.dup
  end

  def apply_inp(a, b)
    mem[a] = b
  end

  def apply_op(op, a, b)
    av = mem[a]

    result = case op
             when "add"
               av + b
             when "mul"
               av * b
             when "div"
               av / b
             when "mod"
               av % b
             when "eql"
               av == b ? 1 : 0
             when "memadd"
               av + mem[b]
             when "memmul"
               av * mem[b]
             when "memdiv"
               av / mem[b]
             when "memmod"
               av % mem[b]
             when "memeql"
               av == mem[b] ? 1 : 0
             else
               fail "panic"
             end
    mem[a] = result
  end
end

input = ARGF.readlines(chomp: true).map(&:split)
ip = InstructionParser.new(input)
binding.irb

exit
#n = 44444439731538
n = 13579246899999
loop do
  res = alu.execute(n.to_s.chars)
  break if res.zero?

  puts "#{n} --> #{res}"
  n -= 1
  n -= 1 while n.to_s.include?("0")
end
