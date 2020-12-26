--- New year eve script
local fg = function(f, g)
	return function(x) return f(g(x)) end
end

function init()
	local step = 0
  local state = { 0, 0, 0, 0, 0 }
	local length = #state
	local idx = 1
	local in2 = 0

	local negativeScale = { 0, 3, 5, 11 }
	local positiveScale = { 0, 2, 3, 5, 7, 9, 10 }

	local makeIdx = function(value)
		return math.floor(value - 1) % length + 1
	end

	for i = 1, length, 1 do state[i] = math.random() * 5.0 end

	local render = function()
		output[1].volts = in2
		output[2].volts = state[makeIdx(idx + in2)]
		output[3].volts = step % 4 == 0 and 5 or 0
		output[4].volts = step % 8 == 0 and 5 or 0
	end

	local nextStep = function()
		step = (step + 1) % 64
		idx = makeIdx(idx + 1)

		local lastIn2 = in2
		in2 = input[2].volts

		if (in2 < 0) ~= (lastIn2 < 0) then
			output[1].scale(in2 < 0 and negativeScale or positiveScale)
			output[2].scale(in2 < 0 and negativeScale or positiveScale)
		end

		if in2 < 0 then
			state[idx] = -in2
		end
	end

  input[1]{
    mode = 'change',
   	direction = 'rising',
    change = fg(render, nextStep)
  }
	input[2]{
		mode = 'change',
		threshold = 0.1,
		hysteresis = 0.02,
		direction = 'both',
		change = fg(render, function() in2 = input[2].volts end)
	}

	output[1].scale(positiveScale)
	output[2].scale(positiveScale)

	render()
end
