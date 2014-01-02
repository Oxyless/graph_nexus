define ["ball"], (Ball) ->
	class Solver

		run: (balls, way_size, nb_solutions, solutions, result_required) ->
			solutions = @solve(balls, way_size, nb_solutions, solutions, result_required)

			return solutions


		init_balls: (balls) ->
			for i in [0..balls.length - 1]
				balls[i].used = false


		solve: (balls, way_size, nb_solutions, solutions, result_required) ->
			if solutions.length == 0
				@ways = [ ]

			nb_path_fail = 0

			for i in [1..nb_solutions]
				@init_balls(balls)
				@ttl = 10000000
				@solve_way(balls, [ ], way_size, @ways)
				nb_path_fail += 1 if @ttl <= 0
				nb_path_fail = 0 if @ttl > 0

				if nb_path_fail > 100
					break ;

			@fill_solutions(solutions, nb_solutions, way_size, result_required)

			return solutions

		solve_way: (balls, current_way, way_size, solutions) ->
			unused_balls = @get_unused_balls(balls)
			unused_balls_size = unused_balls.length
			@ttl -= 1

			@randomise_table(unused_balls)

			for i in [0..unused_balls_size - 1]
				current_way.push({ ball: unused_balls[i], value: -1 })
				unused_balls[i].used = true
				lookup = [ ]

				is_success = @solve_node(balls, current_way, way_size, solutions, lookup)

				return true if is_success == true

				unused_balls[i].used = false

				if lookup.length < way_size
					for id, ball of lookup
						for candidate of unused_balls
							if candidate == ball
								unused_balls.remove(ball)
								unused_balls_size = unused_balls.length
								i = 0
								break

				current_way.pop()

			return false

		solve_node: (balls, current_way, way_size, solutions, lookup) ->
			unused_childs = current_way[current_way.length - 1].ball.get_unused_childs()
			unused_childs_size = unused_childs.length
			@ttl -= 1

			if current_way.length == balls.length
				if @is_already_a_solution(solutions, current_way, way_size) == true
					return false
				else
					solutions.push(_.clone(current_way))
					return true

			return false if unused_childs_size == 0 or @ttl <= 0

			if current_way.length % way_size == 0 and current_way.length < balls.length
				return @solve_way(balls, current_way, way_size, solutions)

			for i in [0..unused_childs_size - 1]
				current_way.push({ ball: unused_childs[i], value: -1 })
				unused_childs[i].used = true

				lookup[unused_childs[i].id] = unused_childs[i]

				is_success = @solve_node(balls, current_way, way_size, solutions, lookup)

				return true if is_success == true

				unused_childs[i].used = false
				current_way.pop()

			return false

		randomise_table: (table) ->
			size = table.length

			for i in [0...size]
				j = Math.round(Math.random() * 1000) % size

				pivot = table[i]
				table[i] = table[j]
				table[j] = pivot

		get_unused_balls: (balls) ->
			unused_balls = []
			size = balls.length

			for i in [0..size - 1]
				unused_balls.push(balls[i]) if balls[i].used == false

			return unused_balls

		is_already_a_solution: (solutions, candidate, way_size) ->
			nb_way = candidate.length / way_size
			cpt_node = 0
			cpt_ways = 0

			if solutions.length > 0
				for i in [0...solutions.length]
					solution = solutions[i]
					cpt_ways = 0

					for j in [0...candidate.length] by way_size
						range_candidate_begin = j
						range_candidate_end = j + way_size
						
						for k in [0...solution.length] by way_size
							range_solution_begin = k
							range_solution_end = k + way_size
							cpt_node = 0

							for l in [range_solution_begin...range_solution_end]
								for m in [range_candidate_begin...range_candidate_end]
									if candidate[m].ball == solution[l].ball
										cpt_node += 1

								if cpt_node == way_size
									cpt_ways += 1
									break

					return true if cpt_ways == nb_way
			return false

		draw_solution: (solution) ->
			message = ""
			for i in [0..solution.length - 1]
				message += "#{solution[i].id} "
			console.log message 

		fill_solutions: (solutions, nb_solutions, way_size, result_required) ->
			j = 0

			@randomise_table(@ways)
			for i in [0...nb_solutions]
				solution = _.clone(@ways[j])
				@fill_solution(solution, way_size, result_required)

				solutions.push(solution)

				j += 1
				j = 0 if j >= @ways.length

			return solutions
				
		fill_solution: (solution, way_size, result_required) ->

			for i in [0...solution.length] by way_size
				last_value = 0
				result = 0

				for j in [0...way_size]
					nb_required = way_size - j


					range = @get_range(result, last_value, nb_required, result_required)

					range_modulo = range.end - range.begin
					last_value = Math.round(Math.random() * 10000) % range_modulo + range.begin

					result += last_value

					solution[i + j].value = last_value

		get_range: (result, last_value, nb_required, result_required) ->
			last_candidate = last_value + 1

			if nb_required == 1
				return { begin: result_required - result, end: result_required - result + 1 }

			for candidate in [last_value + 1...result_required]
				tmp_result = result

				for i in [0...nb_required]
					tmp_result += (candidate + i)

				if tmp_result > result_required
					break

				last_candidate = candidate

			return { begin: last_value + 1, end: last_candidate + 1 }



