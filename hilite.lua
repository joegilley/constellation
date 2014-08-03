local json = require("json")
local utility = require("utility")

local hilite = {}

local MAX_HIT_DISTANCE = 30
local HILITE_TIME = 250

function hilite:init(expansion)
    self.expansion = expansion or 75
    -- performWithDelay( 10, function() Runtime:addEventListener("enterFrame", self) end)
end


hilite.exploding = {}
function hilite:highlight(object, referenceX, referenceY)
    if utility.inSet(object, self.exploding) then return end
    
    local explodeInfo = {
        obj = object,
        origX = object.x,
        origY = object.y,
        origScaleX = object.scaleX,
        origScaleY = object.scaleY,
    }
    hilite.exploding[#hilite+1] = exlpodeInfo
    local adjacent, opposite = (object.x - referenceX), (object.y - referenceY)

    local angle = math.atan2( opposite, adjacent )
    local hypotScale = MAX_HIT_DISTANCE / math.sqrt( opposite ^ 2 + adjacent ^ 2 )
    
    local deltaX = adjacent + self.expansion * math.cos( angle ) --* hypotScale
    local deltaY = opposite + self.expansion * math.sin( angle ) --* hypotScale

    local config = {
        time = HILITE_TIME, 
        adjacent = adjacent, 
        opposite = opposite, 
        x=deltaX + object.x, 
        y=deltaY + object.y, 
        xScale = 5,
        yScale = 5,
        origX = object.x, 
        origY = object.y, 
        origXScale = object.xScale,
        origYScale = object.yScale,
        referenceX = referenceX, 
        referenceY = referenceY,
        transition = easing.outBack
    }
    print(json.encode(config, {indent = true}))

    transition.to(object, config)

    timer.performWithDelay( 2000, function() 
            transition.moveTo( object, {
                time=HILITE_TIME, 
                x = config.origX, 
                y = config.origY, 
                xScale = 1, 
                yScale = 1,
                transition = easing.inBack} )
        end
    )

end

hilite.resseting = {}
function hilite:reset(object)

end

function hilite:enterFrame(event) 

end

return hilite