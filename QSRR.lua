--- Quad Shift Register Random
function init()
    local state = { 0, 0, 0, 0 }
    setmetatable(state, {
        __index = {
            randomize = function()
                state[1] = math.random() * 5.0
                state[2] = math.random() * 5.0
                state[3] = math.random() * 5.0
                state[4] = math.random() * 5.0
                state.syncOutputs()
            end,
            shift = function()
                local t = state[1]
                state[1] = state[2]
                state[2] = state[3]
                state[3] = state[4]
                state[4] = t
                state.syncOutputs()
            end,
            syncOutputs = function()
                output[1].volts = state[1]
                output[2].volts = state[2]
                output[3].volts = state[3]
                output[4].volts = state[4]
            end
        }
    })
    state.randomize()

    input[1]{
        mode = 'change' ,
        direction = 'rising',
        change = state.randomize
    }
    input[2]{
        mode = 'change' ,
        direction = 'rising',
        change = state.shift
    }
end
