require 'set'

class SudokuGrid
  REGIONS = [
    [[0,0],[0,1],[0,2],[1,0],[1,1],[1,2],[2,0],[2,1],[2,2]],
    [[0,3],[0,4],[0,5],[1,3],[1,4],[1,5],[2,3],[2,4],[2,5]],
    [[0,6],[0,7],[0,8],[1,6],[1,7],[1,8],[2,6],[2,7],[2,8]],
    [[3,0],[3,1],[3,2],[4,0],[4,1],[4,2],[5,0],[5,1],[5,2]],
    [[3,3],[3,4],[3,5],[4,3],[4,4],[4,5],[5,3],[5,4],[5,5]],
    [[3,6],[3,7],[3,8],[4,6],[4,7],[4,8],[5,6],[5,7],[5,8]],
    [[6,0],[6,1],[6,2],[7,0],[7,1],[7,2],[8,0],[8,1],[8,2]],
    [[6,3],[6,4],[6,5],[7,3],[7,4],[7,5],[8,3],[8,4],[8,5]],
    [[6,6],[6,7],[6,8],[7,6],[7,7],[7,8],[8,6],[8,7],[8,8]]
  ]
  ROWS = (0...9).map{|x| (0...9).map{|y| [x,y]}}
  COLUMNS = (0...9).map{|y| (0...9).map{|x| [x,y]}}
  
  def self.print_region(i)
    (0...9).each do |y|
      puts (0...9).map{|x| REGIONS[i].include?([x,y]) ? 'X' : '.'}.join('')
    end
  end

  def self.from_file(file_path)
    file_lines = File.read(file_path).split("\n")

    raise "File should have 9 lines, not #{file_lines.size}" unless file_lines.size == 9
    raise "Each line should have 9 characters" unless file_lines.all?{|line| line.size == 9}
    raise "Invalid syntax" unless file_lines.all?{|line| line.match?(/(\d|\.){9}/)}

    entries = []

    file_lines.each_with_index do |line, y|
      line.split('').each_with_index do |char, x|
        next unless char.match?(/\d/)
        entries.push({x: x, y: y, value: char.to_i})
      end
    end

    new(entries: entries)
  end

  def initialize(entries: [])
    starter_grid = build_starter_grid()
    entries.each do |entry|
      x,y,value = entry.values_at(:x, :y, :value)
      starter_grid[[x,y]] = value
    end

    @grid = starter_grid
  end

  def print
    (0...9).each do |y|
      puts (0...9).map{|x| @grid[[x,y]].is_a?(Integer) ? @grid[[x,y]] : '.' }.join('')
    end
  end

  def print_possibilities(grid = @grid)
    (0...9).each do |y|
      puts (0...9).map{|x| grid[[x,y]].is_a?(Integer) ? '!' : grid[[x,y]].size }.join('')
    end
  end

  def solve(max_iterations: 10, verbose: false)
    i = 0
    print_possibilities if verbose

    while(i < max_iterations && !is_grid_solved?) do
      i += 1
      puts "======== Start iteration #{i} ========"

      new_grid = @grid.dup

      solved_cells = new_grid.filter{|_,value| value.is_a?(Integer)}

      # Remove illegal possibilities
      solved_cells.each do |(cell_x,cell_y), value|
        cell_row = (0...9).to_a.map{|x| [x,cell_y]}
        cell_column = (0...9).to_a.map{|y| [cell_x,y]}
        cell_region = REGIONS.find{|region| region.include?([cell_x,cell_y])}
        target_coordinates = Set[*cell_row, *cell_column, *cell_region]
        
        target_coordinates.each do |(x,y)|
          next if new_grid[[x,y]].is_a?(Integer)
          new_grid[[x,y]].subtract([value])
          if(new_grid[[x,y]].size == 1)
            new_grid[[x,y]] = new_grid[[x,y]].to_a.first
          end
        end
      end

      # Solve rows, columns and cells
      [ROWS,COLUMNS,REGIONS].each do |collection|
        collection.each do |cells|
          solved_values = cells.map{|(x,y)| new_grid[[x,y]]}.filter{|value| value.is_a?(Integer)}
          remaining_values = Set.new(1..9) - Set.new(solved_values)

          remaining_values.each do |value|
            possible_cells = cells.filter{|(x,y)| new_grid[[x,y]].is_a?(Set) && new_grid[[x,y]].include?(value)}
            if(possible_cells.size == 1) then new_grid[possible_cells.first] = value end
          end
        end
      end

      print_possibilities(new_grid) if verbose

      if new_grid == @grid
        puts "========> Zero progress made after iteration #{i} 😭 Abandoning solve"
        break
      end

      @grid = new_grid
      puts '-'
      print if verbose

      puts "========> #{number_of_solved_cells} / 81 cells solved after iteration #{i}"
    end

    print_final_state(i)
  end

  def is_grid_solved?
    @grid.values.all?{|value| value.is_a?(Integer)}
  end

  def number_of_solved_cells
    @grid.values.count{|value| value.is_a?(Integer)}
  end

  private

  def build_starter_grid
    result = {}

    (0...9).each do |y|
      (0...9).each do |x|
        result[[x,y]] = Set.new(1..9)
      end
    end
    
    result
  end

  def print_final_state(i)
    if(is_grid_solved?)
      puts "Grid solved 🎉"
      print
    else
      puts "Grid not solved after #{i} iterations 😢"
      print
    end
  end
end