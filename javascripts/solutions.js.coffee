define [], () ->
	class Solutions
		way_size: null
		solutions: null
		balls_light: null
		solutions_light: null
		result_required: null

		aff_message: () ->
			if @solutions.length == 0
				("#generate_msg").css("color", "red")
				$("#generate_msg").text("Pas de solution trouvée")
			else
				$("#generate_msg").css("color", "green")
				$("#generate_msg").text("#{@solutions.length} solutions générées")

		display: () ->
			@aff_message()
			@balls_light = []
			@solutions_light = []

			text = ""

			$("#json-solutions").empty()
			for i in [0..@solutions.length - 1]
				solution = @solutions[i]
				
				@solutions_light[i] = []
				for j in [0..solution.length - 1]
					ball = solution[j].ball

					@balls_light[j] = { x: ball.x, y: ball.y, id: ball.id  } if i == 0		
					@solutions_light[i][j] = { id: ball.id, value: solution[j].value }

			@balls_light = JSON.stringify(@balls_light)

			for i in [0...@solutions_light.length]
				line = $('<p></p>')
				line.html('{ "result": ' + @result_required + ', "path": ' + @way_size + ', "nodes": ' + @balls_light + ', "solution": ' +  JSON.stringify(@solutions_light[i]) + '}')
				$("#json-solutions").prepend(line)

			line = $('<p></p>')
			line.html('{ "result": ' + @result_required + ', "path": ' + @way_size + ', "nodes": ' + @balls_light + ', "solutions": ' +  JSON.stringify(@solutions_light) + '}')
			$("#json-solutions").append(line)