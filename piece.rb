

# encoding: utf-8
require 'debugger'


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