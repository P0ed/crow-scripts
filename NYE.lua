--- New year eve script

local F = {
	cat = function(f, g, h)
		return h == nil
			and function(x) return f(g(x)) end
			or function(x) return f(g(h(x))) end
	end,
	equals = function(x)
		return function(y)
			return math.abs(x - y) < 0.02
		end
	end
}

local state = { 0, 1.2, 0.7, 0.9, 1.7 }
setmetatable(state, {
	__index = {
		length = #state,
		contains = function(f)
			for i = 1, state.length do
				if f(state[i]) then return true end
			end
			return false
		end,
		makeIdx = function(value)
			return math.floor(value - 1) % state.length + 1
		end
	}
})

local setScale = (function()
	local scales = { { 0, 2, 3, 5, 7, 9, 10 }, { 0, 3, 5, 11 } }
	return function(scale)
		for i = 1, 2 do output[i].scale(scales[scale] or 'none') end
	end
end)()

function init()
	local idx = 1
	local step = 1
	local in2 = 0
	local lastIn2 = in2
	local vOffset = 0
	local idxOffset = 0

	local render = function()
		output[1].volts = state[state.makeIdx(idx)] + vOffset
		output[2].volts = state[state.makeIdx(idx + idxOffset)]
		output[3].volts = (step - 1) % 4 == 0 and 5 or 0
		output[4].volts = (step - 1) % (in2 < 2.5 and 8 or 2) == 0 and 5 or 0
	end

	local updateIn2 = function()
		in2 = input[2].volts
		vOffset = 2.5 - math.abs(2.5 - in2)
		idxOffset = vOffset * 2
	end

	local nextStep = function()
		step = step % 24 + 1
		idx = state.makeIdx(idx + 1)

		if in2 > 2.5 and not state.contains(F.equals(vOffset)) then
			state[idx] = vOffset
		end

		if (lastIn2 < 2.5) ~= (in2 < 2.5) then
			setScale(in2 < 2.5 and 1 or 2)
		end

		lastIn2 = in2
	end

  input[1]{
    mode = 'change',
   	direction = 'rising',
    change = F.cat(render, nextStep, updateIn2)
  }
	input[2]{
		mode = 'stream',
		time = 1 / 480,
		stream = function(v)
			if not F.equals(v)(in2) then
				updateIn2()
				render()
		 	end
		end
	}

	setScale(1)
	render()
end
