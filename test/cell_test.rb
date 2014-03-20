require 'minitest/autorun'
require_relative '../lib/cell'

class CellTest < Minitest::Test

  def setup
    @cell = Cell.new(0)
    row = slice([0,5,0,9,0,4,0,0,0])
    column = slice([2,0,0,0,8,0,0,0,1])
    box = slice([2,0,0,0,5,0,0,3,7])
    @cell.add_slice(row)
    @cell.add_slice(column)
    @cell.add_slice(box)
  end

  def test_cell_knows_its_neighbours
    set = Set.new
    set.merge([1,2,3,4,5,7,8,9])
    assert_equal set, @cell.send(:neighbours) 
  end

  def test_cell_can_be_solved
    @cell = Cell.new(0)
    row = slice([6,1,5,0,9,7,8,0,2])
    column = slice([0,1,5,3,6,9,0,8,2])
    box = slice([0,9,7,1,0,0,5,6,8])
    @cell.add_slice(row)
    @cell.add_slice(column)
    @cell.add_slice(box)
    @cell.solve!
    assert_equal 4, @cell.value
  end

  def test_cell_can_be_solved
    refute @cell.solved?
    @cell.solve!
    assert @cell.solved?
  end

private

  def slice(array)
    array.map {|v| Cell.new(v)}
  end

end