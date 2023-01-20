# frozen_string_literal: true

def show(grid)
  puts grid.map(&:join).join("\n")
  puts
end

def step(grid)
  new_grid = grid.dup
  new_grid.map! do |row|
    can_move = row.each_with_index.select { |c, i|
      c == ">" && row[(i + 1) % row.size] == "."
    }
    new_row = row.dup
    can_move.each do |_, i|
      new_row[i] = "."
      new_row[(i + 1) % row.size] = ">"
    end
    new_row
  end

  new_grid = new_grid.transpose

  new_grid.map! do |row|
    can_move = row.each_with_index.select { |c, i|
      c == "v" && row[(i + 1) % row.size] == "."
    }
    new_row = row.dup
    can_move.each do |_, i|
      new_row[i] = "."
      new_row[(i + 1) % row.size] = "v"
    end
    new_row
  end
  new_grid.transpose
end

grid = ARGF.readlines(chomp: true).map(&:chars)

puts "Initial state:"
show(grid)

step = 0
loop do
  step += 1
  new_grid = step(grid)
  #puts "After #{step} steps:"
  #show(new_grid)

  break if new_grid.zip(grid).all? { |new, old| new == old }
  grid = new_grid
end
puts step
