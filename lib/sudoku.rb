class Sudoku
  
  COLUMN_SIZE = 9
  SIZE = COLUMN_SIZE * COLUMN_SIZE
  BOX_SIZE = Math.sqrt(COLUMN_SIZE)

  attr_reader :cells
  private :cells

  def initialize(args)
    raise "Wrong number of values given, #{SIZE} expected" unless args.length == SIZE
    initialize_cells(args)
  end

  def to_s
    @cells.map(&:value).join
  end


  # The to_board method creates this board representation for output
  #
  # 6 1 5 | 4 9 3 | 8 7 2
  # 3 4 8 | 1 2 7 | 9 5 6
  # 2 7 9 | 5 6 8 | 4 3 1
  # ---------------------
  # 4 9 6 | 8 3 2 | 5 1 7
  # 5 2 1 | 7 4 6 | 3 8 9
  # 7 8 3 | 9 1 5 | 2 6 4
  # ---------------------
  # 9 5 2 | 6 8 1 | 7 4 3
  # 8 6 4 | 3 7 9 | 1 2 5
  # 1 3 7 | 2 5 4 | 6 9 8
  def to_board
    values = @cells.map(&:value) # get the values out of the cell objects
    rows = values.each_slice(COLUMN_SIZE).map do |row| # take every 9 values (that's a row)
      row_with_separators = row.insert(3, '|').insert(7, '|') # insert two vertical separators
      row_with_separators.join(" ") # join the values and separators into a string     
    end
    separator = '-' * rows.first.length # that's the horizontal separator
    rows.insert(3, separator).insert(7, separator) # insert two horizontal separators
    # an array of rows is returned, so we can then do "puts sudoku.to_board"
  end

  def solved?
    @cells.all? {|cell| cell.solved? }
  end

  def solve!        
    outstanding_before, looping = SIZE, false
    while !solved? && !looping
      try_to_solve!
      outstanding         = @cells.count {|c| c.solved? }
      looping             = outstanding_before == outstanding
      outstanding_before  = outstanding
    end
    try_harder unless solved?
  end

private

  def replicate!
    self.class.new(self.to_s)
  end

  def steal_solution(source)
    initialize_cells(source.to_s)        
  end

  def try_harder
    blank_cell = @cells.reject(&:solved?).first
    blank_cell.candidates.each do |candidate|
      blank_cell.assume(candidate)
      board = replicate!
      board.solve!
      steal_solution(board) and return if board.solved?
    end
  end

  def try_to_solve!
    @cells.each do |cell|        
      cell.solve! unless cell.solved?                
    end      
  end

  def rows(cells)
    (0..COLUMN_SIZE-1).inject([]) do |rows, index|
      rows << cells.slice(index * COLUMN_SIZE, COLUMN_SIZE)
    end
  end

  def columns(cells, rows)
    (0..COLUMN_SIZE-1).inject([]) do |cols, index|
      cols << rows.map{|row| row[index]}
    end
  end

  def boxes(rows)    
    (0..BOX_SIZE-1).inject([]) do |boxes, i|
      relevant_rows = rows.slice(BOX_SIZE * i, BOX_SIZE)
      boxes + relevant_rows.transpose.each_slice(BOX_SIZE).map(&:flatten)       
    end        
  end
  
  def initialize_cells(digits)
    cells       = digits.split('').map {|v| Cell.new(v) }    
    rows        = rows(cells)
    columns     = columns(cells, rows)
    boxes       = boxes(rows)
    [columns, rows, boxes].each do |slices|
      slices.each {|group| group.each{|cell| cell.add_slice(group)}}
    end
    @cells = cells
  end

end
