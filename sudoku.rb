 require 'sinatra' # load sinatra
 require_relative './lib/sudoku'
 require_relative './lib/cell'
 
 def random_sudoku
 	# we're using 9 numbers, 1 to 9, and 72 zeros as an input
 	# it's obvious there may be no clashes as all numbers are unique
 	seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
 	sudoku = Sudoku.new(seed.join)
 	# then we solve this (really hard!) sudoku
 	sudoku.solve!
 	# and give the outpout to the view as an array of chars
 	sudoku.to_s.chars
 end
 
 get '/' do # default route for our website
 	@current_solution = random_sudoku
 	erb :index
 end