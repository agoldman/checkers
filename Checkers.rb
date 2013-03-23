
# encoding: utf-8
require 'debugger'

class Board

	attr_accessor :matrix

	def initialize(white_player, red_player)
		@matrix = Array.new(8) { [nil] * 8 }
		set_white_pieces(white_player)
		set_red_pieces(red_player)
	end

	def set_white_pieces(white_player)

		0.upto(2) do |r|  #place rows 0 and 2
			if r.even?
				0.upto(7) do |c|
					if c.odd?
						p = Piece.new(:white, self, [r, c], white_player, 1)
						@matrix[r][c] = p
						white_player.add_piece(p)
					end
				end
			end
		end

		0.upto(6) do |c|  #place row 1
			if c.even?
				p = Piece.new(:white, self, [1, c], white_player, 1)
				@matrix[1][c] = p
				white_player.add_piece(p)
			end
		end
	end

	def set_red_pieces(red_player)

		5.upto(7) do |r|  #place rows 5 and 7
			if r.odd? 
				0.upto(6) do |c|
					if c.even?
						p = Piece.new(:red, self, [r,c], red_player, -1)
						@matrix[r][c] = p
						red_player.add_piece(p)
					end
				end
			end
		end

		0.upto(7) do |c|  #place row 6
			if c.odd?
				p = Piece.new(:red, self, [6,c], red_player, -1)
				@matrix[6][c] = p
				red_player.add_piece(p)
			end
		end
	end

	def in_bounds?(position)
		x = position[0]
		y = position[1]
		x >= 0 && x <=7 && y >= 0 && y <= 7
	end

	def remove_piece(position)
		x = position[0]
		y = position[1]
		piece = matrix[x][y]
		matrix[x][y] = nil
		piece.player.remove_piece(piece)
		piece.position = nil
	end

	def make_kill(attempted_move)
		start_pos = attempted_move[0] #[2, 3]
		puts start_pos
		chosen_piece = get_piece(start_pos)
		puts "#{chosen_piece}"
		if chosen_piece.jumping
			end_pos = attempted_move[1]		#[4, 5]
			xdelta = end_pos[0] - start_pos[0]  
			ydelta = end_pos[1] - start_pos[1]  
			x = xdelta > 0 ? 1 : -1
			y = ydelta > 0 ? 1 : -1
			kill_pos = [start_pos[0] + x, start_pos[y] + y]
			remove_piece(kill_pos)
		end
	end

	def add_piece(piece)
		x = piece.position[0]
		y = piece.position[1]
		@matrix[x][y] = piece
	end


	def get_piece(position)
		r = position[0]
		c = position[1]
		@matrix[r][c]
	end

	def move(attempted_move)
		start_pos = attempted_move[0]
		end_pos = attempted_move[1]
		piece = get_piece(start_pos)
		remove_piece(start_pos)
		piece.position = end_pos
		add_piece(piece)
	end

	def render

		render_matrix = Array.new(8) { ["__"] * 8 }
		@matrix.each_with_index do |r, i|
			r.each_with_index do |piece, j|
				unless piece.nil?
					render_matrix[i][j] = piece.render
				end

			end
		end
		render_matrix
	end

end

class Checkers

	attr_accessor :board, :white_player, :red_player

	def initialize
		@white_player = Player.new(:white)
		@red_player = Player.new(:red)
		@board = Board.new(@white_player, @red_player)
		@white_player.set_board(@board)
		@red_player.set_board(@board)
	end

	def show_board
	    puts "    0  1  2  3  4  5  6  7"
	    puts "    -----------------------"
	    puts
	    @board.render.each_with_index do |row, i|
	      print "#{i} | "
	      row.each do |square|
	        print "#{square} "
	      end
	      puts
	      puts
	    end
	end

	def play
		counter = 1
		win = false
		until win
			show_board
			current_player = counter.odd? ? @white_player : @red_player #alternate players
			enemy = counter.odd? ? @red_player : @white_player
			attempted_move = current_player.get_move
			chosen_piece = @board.get_piece(attempted_move[0])
			end_pos = attempted_move[1]
			unless chosen_piece.moves.include?(end_pos)
				"Sorry, that's not a valid move. Please input a valid move."
				attempted_move = current_player.get_move
				chosen_piece = @board.get_piece(attempted_move[0])
				end_pos = attempted_move[1]
			end
			@board.make_kill(attempted_move)
			@board.move(attempted_move)
			counter += 1
			win = win?(current_player, enemy)
		end
		show_board
		puts "You win!" if win

	end

	def win?(player, enemy)

		if !enemy.has_moves? || enemy.all_dead?  #enemy has no legal moves or has lost all their pieces
			return true
		end
	end

end


class Player

	attr_accessor :color, :board, :pieces

	def initialize(color)
		@color = color
		@board = nil
		@pieces = Set.new
	end

	def set_board(board)
		@board = board
	end

	def add_piece(piece)
		pieces.add(piece)
	end

	def remove_piece(piece)
		@pieces.delete(piece)
	end

	def all_dead?
		@pieces.length == 0
	end

	def get_move
		moves = request_move
		until valid_move?(moves)
			puts "Invalid move! Please input a new move."
			moves = request_move
		end
		moves
	end

	def request_move
		puts "#{@color}, please enter a move in the form 'rowcol, rowcol'"
		move = gets.chomp.split(",").map(&:strip)
		move.map! { |e| e.split(//) }
		move.map! { |e| e.map! { |el| el.to_i} }
	end

	def valid_move?(moves) #makes sure user entered numbers and that they are inbounds. makes sure start piece isn't nil and actually
		#belongs to this player

		start_pos = moves[0]
		start_piece = @board.get_piece(start_pos)
		return false if start_piece == nil
		return false unless start_piece.color == @color
		return false unless moves.length == 2

		moves.each do |coord|
			return false unless coord.length == 2
			coord.each do |row_or_col|
				return false unless row_or_col.is_a?(Fixnum) && row_or_col <= 7 && row_or_col >= 0
			end
		end

		true
	end

	def has_moves?
		pieces.each do |piece|
			if !piece.moves.empty?
				return true
			end
		end
		false

	end

end

class Piece

	attr_accessor :color, :size, :board, :position, :player, :jumping


	def initialize(color, size = 1, board, position, player, forward)
		@color = color
		@size = size
		@board = board
		@position = position
		@player = player
		@forward = forward
		@jumping = false
	end

	def render
		@color == :white ? "\u{26AA} " : "\u{26AB} "
	end

	def moves 
		@jumping = false 
		one = [@position[0] + @forward, position[1] - 1] 
		two = [@position[0] + @forward, position[1] + 1] 
		simple_moves = [one, two]
		in_bounds_simple_moves = simple_moves.select { |move| @board.in_bounds?(move) } 
		valid_simples = empty_spaces(in_bounds_simple_moves)
		if valid_simples.length == 2 
			valid_simples
		else
			jumps = find_jumps(@position)
			if jumps.empty?   
				valid_simples
			else
				@jumping = true
				jumps #if you can jump, you must 
			end
		end

	end

	def find_jumps(positon)
		jumps = []
		left = [position[0] + @forward, position[1] - 1]
		right = [position[0] + @forward, position[1] + 1] #hop over
		left_hop = [left[0] + @forward, left[1] - 1]  #hop to
		right_hop = [right[0] + @forward, right[1] + 1]

		if dir_ok(left, left_hop) && dir_ok(right, right_hop)
			jumps = [left_hop] + [right_hop]
		elsif dir_ok(left, left_hop)
			jumps = [left_hop]
		elsif dir_ok(right, right_hop)
			jumps = [right_hop]
		end

		jumps

	end


	# I wrote this recursive search to find if end_positions could be reached by a series of jumps, but it turns out
	# I can implement the game without this. Alas.
	#
	# def find_jumps_deep(position)
	# 	jumps = []
	# 	left = [position[0] + @forward, position[1] - 1]
	# 	right = [position[0] + @forward, position[1] + 1] #hop over
	# 	left_hop = [left[0] + @forward, left[1] - 1]  #hop to
	# 	right_hop = [right[0] + @forward, right[1] + 1]

	# 	if dir_ok(left, left_hop) && dir_ok(right, right_hop)
	# 		left_rest = find_jumps(left_hop)
	# 		right_rest = find_jumps(right_hop)
	# 		if !left_rest.empty? && !right_rest..empty?  #if you can keep jumping, you must 
	# 			jumps = left_rest + right_rest
	# 		elsif !left_rest.empty?
	# 			jumps =left_rest
	# 		elsif !right_rest.empty?
	# 			jumps = right_rest
	# 		else
	# 			jumps = [left_hop, right_hop]
	# 		end

	# 		#jumps = [left_hop, right_hop] + find_jumps(left_hop) + find_jumps(right_hop)
	# 	elsif dir_ok(left, left_hop)
	# 		left_rest = find_jumps(left_hop)
	# 		if !left_rest.empty?				#if you can keep jumping, you must 
	# 	    	jumps = find_jumps(left_hop)
	# 	    else
	# 			jumps = [left_hop] 
	# 		end

	# 	elsif dir_ok(right, right_hop)
	# 		right_rest = find_jumps(right_hop)
	# 		if !right_rest.empty?				#if you can keep jumping, you must 
	# 			jumps = find_jumps(right_hop)
	# 		else
	# 			jumps = [right_hop]
	# 		end
	# 	end

	# 	jumps
	# end

	def dir_ok(direction, dir_hop)  
		@board.in_bounds?(dir_hop) && 
		@board.get_piece(dir_hop).nil?  && 
		!@board.get_piece(direction).nil? && 
		@board.get_piece(direction).color != @color
	end

	def valid_hop?(move)
		@board.get_piece(move) != nil 
	end

	def empty_spaces(moves)
		moves.select { |move| @board.get_piece(move).nil? } 
	end

end

 # c = Checkers.new
 # c.show_board
 # piece = Piece.new(:white, c.board, [1, 2], c.white_player, 1)
 # piece2 = Piece.new(:red, c.board, [2, 1], c.red_player, -1)
 # c.board.remove_piece([2,1])
 # c.board.add_piece(piece2)
 # c.board.remove_piece([5, 2])
 # piece3 = Piece.new(:red, c.board, [4, 1], c.red_player, -1)
 # c.board.add_piece(piece3)
 # c.show_board
 # p piece.moves
#expect  [3, 0] plus prompt to jump again(jump is valid, so must jump)

##comment out the above before testing the below
# c = Checkers.new
# c.show_board
# piece = Piece.new(:red, c.board, [3, 4], c.red_player, -1)
# piece2 = Piece.new(:red, c.board, [3, 6], c.red_player, -1)
# c.board.add_piece(piece)
# c.board.add_piece(piece2)
# c.show_board
# jumper = c.board.get_piece([2,5])
# p jumper.moves
# #expect [4, 7] - can jump in either direction
# c.board.remove_piece([6,5])
# c.show_board
# p jumper.moves
# #expect [6, 5] - must follow longest jump

##comment out the above before testing the below
# testing kills
# c = Checkers.new
# piece1 = Piece.new(:red, c.board, [3, 4], c.red_player, -1)
# c.board.add_piece(piece1)
# c.show_board
# piece2 = c.board.get_piece([2,3])
# piece2.jumping = true
# c.board.make_kill([[2,3], [4,5]])
# c.board.move([[2,3], [4,5]])
# c.show_board




