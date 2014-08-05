local Proxy = { }

function Proxy.get ( object )
    -- Metatables start from blank, or near blank tables
    local proxy = { }
    proxy.raw = object

    -- Use this to fix built-in corona functions
    proxy._class = object._class
    proxy._proxy = object._proxy

    -- Define metatable
    local metatable = {
        -- table[key] is accessed
        __index = function ( t, key )
            return object[key]
        end,

        -- value written to table[key]
        __newindex = function ( t, key, value )
            object[key] = value
            object:dispatchEvent {
                name = "propertyUpdate",
                target = t,
                key = key,
                value = value,
            }
        end
    }

    -- Set metatable and return proxy
    setmetatable ( proxy, metatable )
    return proxy
end

return Proxy