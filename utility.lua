local U = {}

function U.inSet(object, set)
    for _, key in ipairs(set) do
        if set[key] then return true end
    end
    return false
end

function U.notInSet(object, set)
    return not U.inSet(object, set)
end

return U