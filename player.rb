
# encoding: utf-8
require 'debugger'


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