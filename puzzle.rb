# 8:05 start time

class Cell
  attr_reader :x, :y, :filled

  def initialize(x, y)
    @x = x
    @y = y
    @completed = false
    @filled = false
  end

  def completed?
    @completed
  end

  def fill_in
    @filled = true
    @completed = true
  end

  def set_blank
    @filled = false
    @completed = true
  end
end

class Puzzle
  attr_reader :grid,
              :grid_width,
              :grid_height,
              :col_clues,
              :row_clues

  def initialize(grid_width, grid_height, col_clues, row_clues)
    @grid_width = grid_width
    @grid_height = grid_height
    @col_clues = col_clues
    @row_clues = row_clues
    @grid = {}
    build_empty_grid
  end

  def build_empty_grid
    grid_height.times do |row_num|
      grid_width.times do |col_num|
        grid[[row_num, col_num]] = Cell.new(row_num, col_num)
      end
    end
  end

  def print
    output = ''
    grid_height.times do |row|
      grid_width.times do |column|
        if grid[[row, column]].filled
          output += "x"
        else
          output += "-"
        end
      end
      output += "\n"
    end
    puts output
  end

  def process_clues
    # process columns
    grid_width.times do |col_number|
      column_cells = get_cell_list_by_column(col_number)
      clue_list = col_clues[col_number]
      do_processing(column_cells, clue_list)
    end

    grid_height.times do |row_number|
      row_cells = get_cell_list_by_row(row_number)
      clue_list = row_clues[row_number]
      do_processing(row_cells, clue_list)
    end
  end

  private

  def do_processing(cell_list, clue_list)
    process_cell_list(cell_list, clue_list)
    fill_perfect_fit(cell_list, clue_list)
  end

  def process_cell_list(cell_list, clue_list)
    return if cell_list.all? { |cell| cell.completed? }

    if clue_list.length == 1
      clue = clue_list.first
      if clue > (cell_list.length / 2)
        fill_majority_middle(cell_list, clue)
      end
    end
  end

  def fill_majority_middle(cell_list, majority_size)
    # if there's only one clue in the clue group which indicates that the majority of the cells in
    # a row or column are filled, then fill in the middle.
    list_length = cell_list.length
    num_cells_to_fill_in = ((majority_size / 2 * 2) - (list_length / 2)) * 2
    to_leave_blank_size = (list_length - num_cells_to_fill_in) / 2
    start_idx = to_leave_blank_size
    end_idx = to_leave_blank_size + num_cells_to_fill_in - 1
    cell_list[start_idx..end_idx].each { |cell| cell.fill_in }
  end

  def fill_perfect_fit(cell_list, clue_list)
    # if exactly one space goes between each clue, it's a perfect fit
    return unless clue_list.reduce(:+) + clue_list.length - 1 == cell_list.length
    idx = 0
    clue_list.each do |clue|
      clue.times do |i|
        cell_list[idx].fill_in
        idx += 1
      end

      if idx < cell_list.length
        cell_list[idx].set_blank
        idx += 1
      end
    end
  end

  def get_cell_list_by_column(col_num)
    result = []
    grid_height.times do |row_num|
      result << grid[[row_num, col_num]]
    end
    result
  end

  def get_cell_list_by_row(row_num)
    result = []
    grid_width.times do |col_num|
      result << grid[[row_num, col_num]]
    end
    result
  end
end

column_clues = [
  [5, 2],
  [4, 2, 1],
  [3, 4],
  [1, 1, 5,],
  [4],
  [4],
  [1, 5],
  [2, 4],
  [7, 1],
  [5, 2],
]

row_clues = [
  [3, 1],
  [3, 2],
  [4, 4],
  [2, 3],
  [1, 1, 1, 2],
  [2, 4, 2],
  [8],
  [6],
  [10],
  [1, 1, 1, 1],
]

puzzle = Puzzle.new(column_clues.length, row_clues.length, column_clues, row_clues)
puzzle.process_clues
puzzle.print
