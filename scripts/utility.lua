local U = {}

function U.inSet(set, object)
    for _, value in ipairs(set) do
        if value == object then return true end
    end
    return false
end

function U.notInSet(set, object)
    return not U.inSet(object, set)
end

return U