require_relative './SudokuGrid'

SudokuGrid.from_file('./easy_sudoku.txt').solve(verbose: true)
# SudokuGrid.print_region(8)