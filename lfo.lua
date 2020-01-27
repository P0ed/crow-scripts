local rate = 1
local multiply = 1

local lastTrig = 0

local rateRef = function() return rate / multiply end
local halfRateRef = function() return rate / multiply / 2 end

function init()

    input[1] {
        mode = 'change',
        direction = 'rising'
    }
    input[1].change = function()
        local t = time()
        local dt = t - lastTrig
        lastTrig = t
        rate = dt
    end

    input[2] {
        mode = 'change',
        hysteresis = 1
    }
    input[2].change = function(v)
        multiply = 2 ^ math.floor(v)
    end

    output[1].action = loop {
        to(5.0, halfRateRef),
        to(0.0, halfRateRef)
    }
    output[1]()

end
