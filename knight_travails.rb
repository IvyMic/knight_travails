
=begin
  chess board is an 8x8 array:
  0,0 0,1 0,2 0,3 0,4 0,5 0,6 0,7
  1,0 1,1 1,2 1,3 1,4 1,5 1,6 1,7
  2,0 2,1 2,2 2,3 2,4 2,5 2,6 2,7
  3,0 3,1 3,2 3,3 3,4 3,5 3,6 3,7
  4,0 4,1 4,2 4,3 4,4 4,5 4,6 4,7
  5,0 5,1 5,2 5,3 5,4 5,5 5,6 5,7
  6,0 6,1 6,2 6,3 6,4 6,5 6,6 6,7
  7,0 7,1 7,2 7,3 7,4 7,5 7,6 7,7
=end

class Board
attr_accessor :game_board

  def initialize
    @knight_piece = "♞"
    @game_board = Array.new(8) { Array.new(8, " ") }
  end

  def display_board
    print "  "
    8.times.each{ print "+----"}
    puts "+"
    @game_board.each_index do |row|
      print "#{row} "
      @game_board[row].each_index do |column|
        print "| #{@game_board[row][column]}  "
      end
      puts "|"
      print "  "
      8.times.each{ print "+----"}
      puts "+"
    end
    print "  "
    (0..7).each { |e| print "  #{e}  "  }
    puts ""
  end

  def update_position(x,y)
    @game_board[x][y] = @knight_piece
  end

  def reset(x,y)
    @game_board[x][y] = " "
  end
end

=begin
Establish a parent children relationship, where the parent is the square position
that youre located on, and the children are all the possible moves you could make
the first square Position created has a parent of nil by default because that is
your starting point.
=end
class Position
  attr_reader :x, :y, :parent, :children
  def initialize(x, y, parent = nil)
    @x = x
    @y = y
    @parent = parent
    #children are the possible moves
    @children = []
  end

  def get_poss_moves
    #quarter circle forward punch
    #knight goes two steps forward, then one step sideways(either direction)
    move_list = [
                  [@x + 2, @y - 1],
                  [@x + 2, @y + 1],
                  [@x - 2, @y - 1],
                  [@x - 2, @y + 1],

                  [@x - 1, @y + 2],
                  [@x - 1, @y - 2],
                  [@x + 1, @y + 2],
                  [@x + 1, @y - 2]
                ]

    #make sure move is not out of bounds
    possible_moves = move_list.select { |e|
      (e[0] >= 0) && (e[0] <= 7) && (e[1] >= 0) && (e[1] <= 7)
    }
    @children = possible_moves.map { |coordinate|
      Position.new(coordinate[0], coordinate[1], self)
    }
  end
end

=begin
  this uses BFS to traverse a tree from the root to the search object
  it will return the search object, however, in a form that has a parent.
  and that parent will have a parent etc until we are at the root
=end

def get_target_value(target, root)
  queue = []
  queue.push(root)
  loop do
    location = queue.shift
    return location if location.x == target.x && location.y == target.y
    location.get_poss_moves.each { |e| queue.push(e) }
  end
end

=begin
using what we have built prior, the get_route method will take the start
and end as parameters. build two position objects. using the BFS method,
it goes to the destination (the search_obj) and appends its x and y coord
to a route array, locates it parent and then appends its x and y coord to
the route array. continues to do this until parent == nil ie we're at the root
and now the route array has all the coordinates for the moves
=end
def get_route(start_arr, end_arr)
  root = Position.new(start_arr[0], start_arr[1])
  target = Position.new(end_arr[0], end_arr[1])
  solution = get_target_value(target, root)

  route = []
  route.unshift([target.x, target.y])
  location = solution.parent
  until location == nil
    route.unshift [location.x, location.y]
    location = location.parent
  end
  return route
end

def post_results(x,y)
  @board = Board.new
  route = get_route(x,y)

  puts "It took #{route.length - 1} moves"
  count = 0
  route.each_with_index do |e,i|
    if i == 0
      puts "You start here:\n"
      @board.update_position(e[0],e[1])
      @board.display_board
      @board.reset(e[0],e[1])
    else
      puts "\nThis is move number: #{count+1}"
      @board.update_position(e[0],e[1])
      @board.display_board
      @board.reset(e[0],e[1])
      count += 1
    end
  end

  puts "\nList of your moves: "
  route.each { |e| e.inspect }
end

post_results([0,0],[3,4])
