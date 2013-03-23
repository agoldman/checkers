
# encoding: utf-8
require 'debugger'
require './board.rb'
require './player.rb'
require './piece.rb'

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
			kill_n_move(attempted_move)
			check_jump(chosen_piece, current_player)
			counter += 1
			win = win?(current_player, enemy)
		end

		show_board
		puts "You win!" if win
	end

	def check_jump(chosen_piece, current_player)
		while chosen_piece.jumping  #if you have more jumps available, you must take them
			if !chosen_piece.find_jumps(chosen_piece.position).empty?
				show_board
			    puts "Another jump is available. You must keep jumping!"
				attempted_move = current_player.get_move
				new_chosen_piece = @board.get_piece(attempted_move[0])
				if new_chosen_piece != chosen_piece
					puts "Cheater! That wasn't your jumping piece. You lose your turn."
					chosen_piece.jumping = false
				else
					kill_n_move(attempted_move)
				end
			else
				chosen_piece.jumping = false
			end
		end
		
	end


	def kill_n_move(move)
		@board.make_kill(move)
		@board.move(move)
	end

	def win?(player, enemy)

		if !enemy.has_moves? || enemy.all_dead?  #enemy has no legal moves or has lost all their pieces
			return true
		end
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

c = Checkers.new
c.play



