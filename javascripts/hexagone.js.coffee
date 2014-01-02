define [], () ->
	class Hexagone
		pos_x: 0
		pos_y: 0
		side: 0
		shape: null
		stage: null
		balls: null

		constructor: (@stage, @pos_x, @pos_y, @side) ->
			@balls = [ ]
			@shape = new createjs.Shape()
			graphics = @shape.graphics

			graphics.moveTo(@pos_x +  @side * Math.cos(0), @pos_y +  @side *  Math.sin(0));

			graphics.beginFill("#aaaaaa")
			for i in [1..6]
				graphics.lineTo(@pos_x + @side * Math.cos(i * 2 * Math.PI / 6), @pos_y + @side * Math.sin(i * 2 * Math.PI / 6))
			graphics.closePath()

		draw: () ->
			@stage.addChild(@shape)
			

		
