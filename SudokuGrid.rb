class SudokuGrid
  def self.from_file(file_path)
    file_lines = File.read(file_path).split('\n')

    raise "File should have 9 lines, not #{file_lines.size}" unless file_lines.size == 9
    raise "Each line should have 9 characters" unless file_lines.all?{|line| line.size == 9}
    raise "Invalid syntax" unless file_lines.all?{|line| line.match?((\d|\.){9})}

    entries = []

    file_lines.each_with_index do |line, y|
      line.split('').each_with_index do |char, x|
        next unless char.match?(/\d/)
        entries.push({x: x, y: y, value: char})
      end
    end

    puts entries.to_s
  end
end