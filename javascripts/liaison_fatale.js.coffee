# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

require ["grid", "solutions"], (Grid, Solutions) ->
	grid_base = new Grid("hexagone-base")
	grid_solutions = new Solutions()
	solutions = null
	old_size = 4
	grid_base.set_size(4)

	update_size = (slider) ->
		size = Math.round($(slider).val())

		if size != old_size
			if 0 < size < 6
				grid_base.set_size(size) 
				old_size = size
			else
				$(this).attr("value", old_size)

			grid_base.calc_elements()
			grid_base.draw()
		
	$("#generate-btn").click ->
		way_size = (Number) $("#way_size_input")[0].value
		nb_solutions = (Number) $("#nb_grid_input")[0].value
		result_required = (Number) $("#result_input ")[0].value
		nb_balls = grid_base.nb_actives
		result = 0

		for i in [1..way_size]
			result += i

		$("#generate_msg").text("")
		if way_size <= 0
			$("#generate_msg").css("color", "red")
			$("#generate_msg").text("Taille invalide")
		else if nb_balls % way_size != 0 or nb_balls <= 0
			$("#generate_msg").css("color", "red")
			$("#generate_msg").text("Nombre de boules invalide")

		else if result > result_required
			$("#generate_msg").css("color", "red")
			$("#generate_msg").text("Resultat impossible")
		else
			solutions = grid_base.generate_solutions(way_size, nb_solutions, result_required)
			grid_solutions.result_required = result_required
			grid_solutions.solutions = solutions
			grid_solutions.way_size = way_size

			grid_solutions.display()

	$("#way_size_input").change ->
		grid_base.solutions = []

	$("#result_input").change ->
		grid_base.solutions = []

	$(".slider_size").noUiSlider({ range: [1, 5], start: 4, handles: 1, connect: "lower", slide: () -> update_size(this) })

	grid_base.calc_elements()
	grid_base.draw()