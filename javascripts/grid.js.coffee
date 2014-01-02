define ["ball", "hexagone", "solver"], (Ball, Hexagone, Solver) ->
	class Grid
		numberOfSides: 6
		canvas_id: null
		stage: null

		solver: null
		balls: null
		hexagones: null

		solutions: null
		nb_actives: 0
		h_offset: null
		v_offset: null
		x_center: null
		y_center: null
		ball_ids: 1
		side: null
		circle: 12
		scale: 1
		size: 1

		text_actives: null

		constructor: (@canvas_id) ->
			@stage = new createjs.Stage(@canvas_id)
			@hexagones = [ ]
			@balls = [ ]
			@solver = new Solver()
			@set_size()


		set_size: (size) ->
			@size = size
			@side = @scale * 50

			@h_offset = @side
			@v_offset = @side * 0.86

			@circle = @circle

			@stage.canvas.width = @h_offset * 2 * (9) + 50
			@stage.canvas.height = @v_offset * 2 * (9) + 50

			@x_center = @stage.canvas.width / 2
			@y_center = @stage.canvas.height / 2

			@solutions = []


		calc_shapes_req: (x, y, size, from) ->
 			hexagone = @add_hexagone(x, y)
 			@calc_hexagone_balls(hexagone, x, y)

 			if size > 1
	 			size = size - 1

	 			@calc_shapes_req(x, y + @v_offset * 2, size)
	 			@calc_shapes_req(x + @h_offset * 1.5, y - @v_offset, size)
	 			@calc_shapes_req(x + @h_offset * 1.5, y + @v_offset, size)

	 			@calc_shapes_req(x, y - @v_offset * 2, size)
	 			@calc_shapes_req(x - @h_offset * 1.5, y + @v_offset, size)
	 			@calc_shapes_req(x - @h_offset * 1.5, y - @v_offset, size)

	 	calc_hexagone_balls: (hexagone, x, y) ->
	 		x_start = x - @h_offset
	 		y_start = y - @v_offset

	 		x_limit = 2
	 		y_limit = 3

	 		x = 0
	 		y = 0

	 		offset = 0

	 		for i in [0..y_limit - 1]
	 			x_limit = if i % 2 == 0 then 2 else 3

	 			for j in [0..x_limit - 1]
	 				offset = if i % 2 == 0 then @h_offset / 2 else 0

	 				x = x_start + (j * @h_offset) + offset
	 				y = y_start + (i * @v_offset)

	 				hexagone.balls["#{x}-#{y}"] = @add_ball(x, y, ((x - 50) / @h_offset), Math.round((y - 50) / @v_offset))	

		add_ball: (pos_x, pos_y, x, y) ->
			if not @balls["#{x}-#{y}"]?
				@balls["#{x}-#{y}"] = new Ball(@stage, pos_x, pos_y, @circle, x, y, @ball_ids)
				@balls["#{x}-#{y}"].shape.addEventListener("click", (e) => @clickBallHandle(@balls["#{x}-#{y}"]) )
				@ball_ids += 1

			return @balls["#{x}-#{y}"]

		add_hexagone: (x, y) ->
			if not @hexagones["#{x}-#{y}"]?
				@hexagones["#{x}-#{y}"] = new Hexagone(@stage, x, y, @side)
				@hexagones["#{x}-#{y}"].shape.addEventListener("click", (e) => @clickHexagoneHandle(@hexagones["#{x}-#{y}"]))
			return @hexagones["#{x}-#{y}"]
 
		draw_hexagones: () ->
			for id, hexagone of @hexagones
				hexagone.draw()

		draw_balls: () ->
			for id, ball of @balls
				ball.draw()

		clickBallHandle: (ball) ->
			ball.active = not ball.active
			color = if ball.active == true then "eeeeee" else "888888"

			ball.color = color

			if ball.active == true
				@nb_actives += 1
			else
				@nb_actives -= 1

			@solutions = [ ]
			@update_actives()
			@draw()
			

		clickHexagoneHandle: (hexagone) ->
			for id, ball of hexagone.balls
				@clickBallHandle(ball)

		calc_elements: () ->
			@ball_ids = 0
			@balls = [ ]
			@hexagones = [ ]
			@nb_actives = 0

			@calc_shapes_req(@x_center, @y_center, @size)
			@clickHexagoneHandle(@hexagones["#{@x_center}-#{@y_center}"])

		draw: () ->
			@stage.removeAllChildren()
			@stage.addChild(@text_actives)
			
			@draw_hexagones()
			@draw_balls()

			@update_actives()
			@stage.update()

		update_actives: () ->
			if not @text_actives?
				@text_actives = new createjs.Text("#{@nb_actives}", "12px Arial", "#ffffff")
				@text_actives.x = 50
				@text_actives.y = 50
				@stage.addChild(@text_actives)

			@text_actives.text = "Nombre de boules actives: #{@nb_actives}"
			

		get_random_color: () ->
		    letters = '0123456789ABCDEF'.split('')
		    color = '#'

		    for i in [0..5]
		        color += letters[Math.round(Math.random() * 15)]

		    return color;

		print_way: (way, way_size) ->
			pas = way_size
			nb_way = way.length / way_size
			color_way = []
			

			for i in [0..nb_way]
				color_way.push(@get_random_color())

			for i in [0..way.length - 1]
				ball = way[i].ball
				if i % way_size == 0
					shape = new createjs.Shape()
					graphics = shape.graphics
					graphics.moveTo(ball.pos_x, ball.pos_y)
					color = color_way.pop()
					@stage.addChild(shape)
					graphics.beginStroke("#000000")
				else	
					graphics.lineTo(ball.pos_x, ball.pos_y)

				ball.shape.graphics.beginFill(color).drawCircle(ball.pos_x,ball.pos_y, ball.circle)

				ball.text.text = way[i].value
				@stage.addChild(ball.text)

		generate_solutions: (way_size, nb_solutions, result_required) ->
			balls = @generate_childs()

			@solutions = @solver.run(balls, way_size, nb_solutions, @solutions, result_required)
			@draw()
			@print_way(@solutions[@solutions.length - 1], way_size) if @solutions.length > 0
	
			@stage.update()

			return @solutions

		generate_childs: () ->
			balls = []

			for id, ball of @balls
			 	balls["#{ball.x}-#{ball.y}"] = ball if ball.active == true

			sequenced_balls = []

			for id, ball of balls
				ball.childs = [ ]
				x = ball.x
				y = ball.y
				candidates = [ "#{x-1}-#{y}", "#{x+1}-#{y}", "#{x+0.5}-#{y-1}", "#{x-0.5}-#{y-1}", "#{x+0.5}-#{y+1}", "#{x-0.5}-#{y+1}" ]

				for i, candidate of candidates
					if balls[candidate]?
						ball.addChild(balls[candidate])

				sequenced_balls.push(ball)

			return sequenced_balls



