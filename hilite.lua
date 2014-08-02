local hilite = {}

local exploding = {}
function hilite.highlightObject(object)
    local explodeInfo = {
        obj = object,
        origX = object.x,
        origY = object.y,
        origScaleX = object.scaleX,
        origScaleY = object.scaleY,
    }
end

local resetting = {}
function hilite.reset(object)

end

return hilite