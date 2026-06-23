extends Node
class_name MathSystem

func generate(type, allow_negative_numbers := false):
	var question
	var answer

	match type:
		"mult":
			var a = randi_range(2, 15)
			var b = randi_range(2, 12)

			if allow_negative_numbers:
				var sign_pattern = randi_range(0, 2)
				if sign_pattern == 0:
					a *= -1
				elif sign_pattern == 1:
					b *= -1
				else:
					a *= -1
					b *= -1

			question = "%s x %s" % [format_number(a), format_number(b)]
			answer = a * b

		"div":
			var b = randi_range(2, 15)
			var result = randi_range(2, 15)
			var a = b * result
			question = "%s / %s" % [format_number(a), format_number(b)]
			answer = result

		"sqrt":
			var list = [
				49, 64, 81, 100, 121, 144, 169, 196, 225,
				256, 289, 324, 361, 400
			]
			var n = list.pick_random()
			question = "√%d" % n
			answer = int(sqrt(n))

		"pow":
			var a = randi_range(2, 8)
			if allow_negative_numbers and randi_range(0, 1) == 0:
				a *= -1

			var b = randi_range(2, 3)
			question = "%s^%d" % [format_number(a), b]
			answer = int(pow(a, b))

		"equation":
			var coefficient = randi_range(2, 12)
			var solution = randi_range(2, 12)
			var constant = randi_range(2, 20)

			if allow_negative_numbers:
				if randi_range(0, 1) == 0:
					coefficient *= -1
				if randi_range(0, 1) == 0:
					solution *= -1
				if randi_range(0, 1) == 0:
					constant *= -1

			var result = coefficient * solution + constant
			question = "%dx %s = %d" % [
				coefficient,
				format_signed_term(constant),
				result
			]
			answer = solution

	return {
		"question": question,
		"answer": answer,
		"options": generate_options(answer, allow_negative_numbers)
	}

func generate_options(correct, allow_negative_numbers := false):
	var options = [correct]
	var variation = maxi(4, int(abs(correct) / 3))

	while options.size() < 3:
		var offset = random_non_zero(-variation, variation)
		var fake = correct + offset
		if (
			fake != correct
			and fake not in options
			and (allow_negative_numbers or fake >= 0)
		):
			options.append(fake)

	options.shuffle()
	return options

func random_non_zero(minimum: int, maximum: int) -> int:
	var value = randi_range(minimum, maximum)
	while value == 0:
		value = randi_range(minimum, maximum)
	return value

func format_number(value: int) -> String:
	if value < 0:
		return "(%d)" % value
	return str(value)

func format_signed_term(value: int) -> String:
	if value < 0:
		return "- %d" % abs(value)
	return "+ %d" % value
