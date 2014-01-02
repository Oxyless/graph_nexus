define [], ->
	class Ball
		pos_x: 0
		pos_y: 0
		circle: 0
		text: null
		active: false
		shape: null
		stage: null

		color: "#888888"
		x: 0
		y: 0

		childs: null
		used: false
		id: 0

		constructor: (@stage, @pos_x, @pos_y, @circle, @x, @y, @id) ->
			@childs = [ ]
			@shape = new createjs.Shape()

			graphics = @shape.graphics

			@text = new createjs.Text("", "12px Arial", "#ffffff")
			@text.x = @pos_x
			@text.y = @pos_y - 7

			@text.textAlign = 'center'

		draw: () ->	
			@shape.graphics.beginFill(@color).drawCircle(@pos_x, @pos_y, @circle)
			@stage.addChild(@shape)

		addChild: (child) ->
			@childs.push(child)

		get_unused_childs: () ->
			unused_childs = [ ]
			size = @childs.length

			for i in [0..size - 1]
				unused_childs.push(@childs[i]) if @childs[i].used == false

			return unused_childs
