local State = setmetatable({}, {
    __call = function(_, t)
        return setmetatable(t, {
            __index = {
                lens = setmetatable({}, {
                    __index = function(w, p)
                        return function()
                            return w[p]
                        end
                    end
                })
            }
        })
    end
})
