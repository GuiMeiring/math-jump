extends Node
class_name MathSystem

func generate(type):
	var question
	var answer

	match type:
		"mult":
			var a = randi_range(1, 10)
			var b = randi_range(1, 10)
			question = "%d x %d" % [a, b]
			answer = a * b

		"div":
			var b = randi_range(1, 10)
			var result = randi_range(1, 10)
			var a = b * result
			question = "%d / %d" % [a, b]
			answer = result

		"sqrt":
			var list = [4, 9, 16, 25, 36]
			var n = list.pick_random()
			question = "√%d" % n
			answer = int(sqrt(n))

		"pow":
			var a = randi_range(2, 5)
			var b = randi_range(2, 3)
			question = "%d^%d" % [a, b]
			answer = int(pow(a, b))

		"fact":
			var n = randi_range(2, 5)
			question = "%d!" % n
			answer = factorial(n)

	return {
		"question": question,
		"answer": answer,
		"options": generate_options(answer)
	}

func generate_options(correct):
	var options = [correct]

	while options.size() < 3:
		var fake = correct + randi_range(-5, 5)
		if fake > 0 and fake != correct and fake not in options:
			options.append(fake)

	options.shuffle()
	return options

func factorial(n):
	var result = 1
	for i in range(1, n + 1):
		result *= i
	return result
