require_relative '../lib/sudoku'
require_relative '../lib/cell'
require 'minitest/autorun'
require 'ruby-debug'

class SudokuTest < Minitest::Test

  def setup
    @sudoku = Sudoku.new '015003002000100906270068430490002017501040380003905000900081040860070025037204600'
    @cells = @sudoku.send(:cells)
  end

  def test_can_solve_really_hard_sudoku   
    skip
    input = "800000000003600000070090200050007000000045700000100030001000068008500010090000400"
    sudoku = Sudoku.new input
    sudoku.solve!
    assert sudoku.solved?
    puts
    puts sudoku.to_board
  end

  def test_can_solve_hard_problems        
    skip
    input = [ # 295637103
      "000 200 001",
      "060 075 000",
      "057 004 060",
      "900 000 608",
      "000 080 000",
      "005 630 040",
      "500 003 000",
      "002 000 930",
      "708 000 014"
    ].join.gsub(' ', '')
    sudoku = Sudoku.new input
    sudoku.solve!    
    assert sudoku.solved?
  end

  def test_solve_empty    
    skip
    input = '0' * 81
    sudoku = Sudoku.new(input)
    sudoku.solve!
    assert sudoku.solved?
    puts
    puts sudoku.to_board
  end

  def test_splitting_input_into_cells    
    assert_equal 81, @cells.length
    assert @cells.all?{|c| c.is_a? Cell}
  end

  def test_boxes_are_generated_correctly
    rows = (0..80).map {|i| Cell.new(i)}.each_slice(9).to_a    
    boxes = @sudoku.send(:boxes, rows) # @sudoku.boxes(rows)
    assert_equal 9, boxes.length    
    boxes.each do |box|
      assert_equal 9, box.length
      assert box.all? {|c| c.is_a? Cell}
    end
  end

  def test_cells_have_references_to_corresponding_sets    
    @cells.each do |c| 
      assert_equal 3, c.slices.length
      c.slices.each do |slice| 
        assert slice.is_a?(Array)
        assert_equal 9, slice.length
        slice.each do |cell|
          assert 3, cell.slices.length
        end
      end
    end
  end

  def test_sudoku_can_be_solved        
    refute @sudoku.solved?    
    @sudoku.solve!    
    assert @sudoku.solved?
    assert_equal '615493872348127956279568431496832517521746389783915264952681743864379125137254698', @cells.map(&:value).join
  end

end