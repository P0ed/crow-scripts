--- chaos / balance
-- in1: clock
-- in2: chaos/balance
-- out1: s&h random 1
-- out2: s&h of crossfade random 1, 2
-- out3: triangle lfo
-- out4: gate sequence

local Seq = {
    make = function(pattern)
        local idx = 0
        local length = #pattern
        return function()
            idx = (idx + 1) % length
            return pattern[idx + 1] == 1 and 5.0 or 0.0
        end
    end
}

function init()
    local state = {
        lastTrig = 0,
        dt = 0
    }
    local seq = Seq.make{1,0}

    local halfDt = function() return state.dt / 2 end
    output[3].action = ar(halfDt, halfDt, 5)

    input[1]{
        mode = 'change' ,
        direction = 'rising',
        change = function()
            local r1 = math.random() * 5.0
            local r2 = math.random() * 5.0
            local c = input[2].volts / 5.0

            local t = time()
            state.dt = (t - state.lastTrig) / 1000.0
            state.lastTrig = t

            output[1].volts = r1
            output[2].volts = r1 * (1 - c) + r2 * c
            output[3]()
            output[4].volts = seq()
        end
    }
end
