 require 'rack-flash'
 require 'sinatra/partial'
 require 'sinatra' # load sinatra 
 require_relative './lib/sudoku'
 require_relative './lib/cell'
 enable :sessions
 set :partial_template_engine, :erb
 set :session_secret, "I'm the secret kety to sign the cookie"
 use Rack::Flash
 
 def random_sudoku
 	seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
 	sudoku = Sudoku.new(seed.join)
 	sudoku.solve!
 	sudoku.to_s.chars
 end

 def puzzle(sudoku)
 	sudoku.map {|x| rand > 0.8 ? "0" : x }
 end
 
 def box_order_to_row_order(cells)
   boxes = cells.each_slice(9).to_a
   # raise boxes.inspect
   (0..8).to_a.inject([]) {|memo, i|
     first_box_index = i / 3 * 3
     three_boxes = boxes[first_box_index, 3]
     three_rows_of_three = three_boxes.map do |box| 
       row_number_in_a_box = i % 3
       first_cell_in_the_row_index = row_number_in_a_box * 3
       box[first_cell_in_the_row_index, 3]
     end
     memo += three_rows_of_three.flatten
   }
 end 
 
 def generate_new_puzzle_if_necessary
 	return if session[:current_solution]
   sudoku = random_sudoku
   session[:solution] = sudoku
   session[:puzzle] = puzzle(sudoku)
   session[:current_solution] = session[:puzzle]
 end 
 
 def prepare_to_check_solution
   @check_solution = session[:check_solution]
   if @check_solution
      flash[:notice] = "Incorrect values are highlighted in yellow"
   end
   session[:check_solution] = nil
 end

 get '/' do # default route for our website
 	prepare_to_check_solution
 	generate_new_puzzle_if_necessary
 	# sudoku = random_sudoku
 	# session[:solution] = sudoku
 	@current_solution = session[:current_solution] || session[:puzzle]
  @solution = session[:solution]
  @puzzle = session[:puzzle]
 	erb :index
 end

 get '/solution' do
 	@current_solution = session[:solution]
 	erb :index
 end

 post '/' do # If I get a POST request to '/' then do this:
 	cells = box_order_to_row_order(params["cell"]) # params is what Chrome calls Form Data in the Network tab  
 	session[:current_solution] = cells
 	session[:check_solution] = true
 	redirect to("/")
 end

 helpers do
  def cell_value(value)
    value.to_i == 0 ? '' : value
  end
 	def colour_class(solution_to_check, puzzle_value, current_solution_value, solution_value)
 		must_be_guessed = puzzle_value == "0"
 		tried_to_guess = current_solution_value.to_i != 0
 		guessed_incorrectly = current_solution_value != solution_value

 		if solution_to_check &&
 				must_be_guessed &&
 				tried_to_guess &&
 				guessed_incorrectly
 			'incorrect'
 		elsif !must_be_guessed
      'value-provided'
    end
  end
 end