# encoding: utf-8
require 'debugger'


class Board

	attr_accessor :matrix

	def initialize(white_player, red_player)
		@matrix = Array.new(8) { [nil] * 8 }
		set_white_pieces(white_player)
		set_red_pieces(red_player)
	end
	# REV: I think you could condense these two together by adding some difference to the r and c values for one of the players
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
		chosen_piece = get_piece(start_pos)
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
