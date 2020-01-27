--- Wheels
function init()
    local mode = 1
    local lastClock = 0
    local dt = 0.5

    local mdt = function() return dt / mode end

    local makeArray = function(count, f)
        local array = {}
        for i = 1, count do array[i] = f(i) end
        return array
    end

    local reduceArray = function(a, f)
        local result
        for i = 1, #a do result = f(a[i], i, result) end
        return result
    end

    local makeTable = function(count)
        return makeArray(count, function(i) return 0 end)
    end

    local makeLoop = function(t)
        return loop(makeArray(
            #t,
            function(i)
                return to(
                    function() return t[i] end,
                    mdt,
                    'now'
                )
            end
        ))
    end

    local randomTable = makeTable(8)

    local printArray = function(a)
        local merged = reduceArray(
            a,
            function(v, i, r)
                if r == nil then
                    return v
                else
                    return r .. ', ' .. v
                end
            end
        )
        print('[' .. (merged or '') .. ']')
    end

    local updateTables = function()
        local steps = math.floor(2 ^ (mode - 1))
        local values = makeArray(steps, function() return math.random() * 5.0 end)

        printArray(randomTable)

        local randomLength = #randomTable
        for i = 1, randomLength do
            local idx = math.floor((i - 1) / (randomLength / steps)) + 1
            randomTable[i] = values[idx]
        end

        printArray(randomTable)
    end

    local clock = function()
        print('clock')

        local c = time()
        dt = (c - lastClock) / 1000
        lastClock = c

        local v = input[2].volts or 0
        local x = (v + 5) / 2.5 + 1
        local newMode = math.floor(math.min(math.max(x, 1), 4))
        if mode ~= newMode then
            mode = newMode
            print(mode)
        end

        updateTables()

        output[1]('restart')
        output[2]('restart')
        -- output[3]('restart')
        -- output[4]('restart')

        print(dt)
    end

    input[1]{
        mode = 'change' ,
        direction = 'rising',
        change = clock
    }
    input[2].mode = 'none'

    output[1](lfo(mdt, 5, 'linear'))
    output[2](makeLoop(randomTable))
    -- output[3](makeLoop(tables[3]))
    -- output[4](makeLoop(tables[4]))
end
