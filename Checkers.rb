
# encoding: utf-8

require 'Set'

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
						@matrix[r][c] = Piece.new(:white, self, [r, c], white_player)
						white_player.add_piece
					end
				end
			end
		end

		0.upto(6) do |c|  #place row 1
			if c.even?
				@matrix[1][c] = Piece.new(:white, self, [1, c], white_player)
				white_player.add_piece
			end
		end
	end

	def set_red_pieces(red_player)

		5.upto(7) do |r|  #place rows 5 and 7
			if r.odd? 
				0.upto(6) do |c|
					if c.even?
						@matrix[r][c] =  Piece.new(:red, self, [r,c], red_player)
						red_player.add_piece
					end
				end
			end
		end

		0.upto(7) do |c|
			if c.odd?
				@matrix[6][c] = Piece.new(:red, self, [6,c], red_player)
				red_player.add_piece
			end
		end
	end

	def get_piece(position)
		r = position[0]
		c = position[1]
		@matrix[r][c]
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
		@white_player = Player.new(:White)
		@red_player = Player.new(:Red)
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
			current_player = counter.odd? ? @white_player : @red_player #alternate players
			enemy = counter.odd? ? @red_player : @white_player
			attempted_move = current_player.get_move
			win = win?(current_player, enemy)
		end
		puts "You win!" if win

	end

	def win?(player, enemy)

		if !enemy.has_moves? || enemy.all_dead?  #enemy has no legal moves or has lost all their pieces
			return true
		end
	end

end


class Player

	attr_accessor :color, :pieces, :board

	def initialize(color)
		@color = color
		@pieces = 0
		@board = nil
	end

	def set_board(board)
		@board = board
	end

	def add_piece
		@pieces += 1
	end

	def remove_piece
		@pieces -= 1
	end

	def all_dead?
		@pieces == 0
	end

	def get_move
		puts "#{@color} please enter a move in the form 'rowcol, rowcol'"
		moves = request_move
		until valid_move?(moves)
			puts "Invalid move! Please input a news move."
			moves = request_move
		end
	end

	def request_move
		move = gets.chomp.split(",").map(&:strip)
		move.map! { |e| e.split(//) }
		move.map! { |e| e.map! { |el| el.to_i} }
	end

	def valid_move?(moves) #makes sure user entered numbers and that they are inbounds. makes sure start piece isn't nil and actually
		#belongs to this player

		start_pos = moves[0]
		start_piece = @board.get_piece(start_pos)
		return false if start_piece == nil
		start_piece.color == @color
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
		puts pieces.count
		pieces.each do |piece|
			if !piece.moves.empty?
				return true
			end
		end
		false

	end

end

class Piece

	attr_accessor :color, :size, :board, :position, :player


	def initialize(color, size = 1, board, positio, player)
		@color = color
		@size = size
		@board = board
		@positon = position
		@player = player
	end

	def render
		@color == :white ? "\u{26AA} " : "\u{26AB} "
	end

	def moves
		[]
	end

end

c = Checkers.new
c.show_boardc.white_player.valid_move?([[0,1],[0,2]])
