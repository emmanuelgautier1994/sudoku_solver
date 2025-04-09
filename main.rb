require_relative './SudokuGrid'

SudokuGrid.from_file('./sample_sudokus/hard_sudoku_1.txt').solve(verbose: true)