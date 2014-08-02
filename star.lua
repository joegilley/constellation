-- fields
local Star = {
    
}

-- private fields, methods
local setupShiftColor, randomFlickerTimer

local starDisplayGroup = display.newGroup()

-- public methods
function Star:new ()
    obj = {
        x = 0,
        y = 0,
        size = 1,
        color = {
            r = 1,
            g = 1,
            b = 1,
        },
        -- The GameObject
        obj = {}
    }
    setmetatable( obj, self )
    self.__index = self

    return obj
end

function Star:init(vals)
    vals = vals or {}
    self.x = vals.x or math.random(0, display.contentWidth)
    self.y = vals.y or math.random(0, display.contentHeight)

    self.size = vals.size or (self.size + math.random(0, 3))

    -- TODO vals.color needs to be shallow copied or it could reference multiple tables
    self.color = vals.color or setupShiftColor(self.color, 2, 0.5)

    self.obj = display.newRect(starDisplayGroup, self.x, self.y, self.size, self.size)
    self.obj:setFillColor( self.color.r, self.color.g, self.color.b )

    randomFlickerTimer(self)

    physics.addBody( self.obj, "static", { isSensor = true } )
end

function Star:flicker(intensity, duration)
    local intensity = intensity or 0.9
    local duration = duration or 100
   
    self.obj:setFillColor( self.color.r*intensity, self.color.g*intensity, self.color.b*intensity )
    timer.performWithDelay( duration, function() self.obj:setFillColor( self.color.r, self.color.g, self.color.b ) end )
end

function randomFlickerTimer (star)
    local randomDelay = math.random(0, 120000)
    timer.performWithDelay( randomDelay, function()
        star:flicker(0.6, 75)
        randomFlickerTimer(star)
    end)
end

function setupShiftColor(initialColor, shiftProbabilityPower, shiftIntensity)
    local color = {}
    color.r, color.g, color.b = initialColor.r, initialColor.g, initialColor.b

    -- This will give a skew towards lower probabilities
    local doShift = math.random()^shiftProbabilityPower
    -- Only the upper 30% of the already skewed probabilities will pass
    if doShift > 0.7 then
        local shift = math.random() * math.min( 1, math.max( 0, shiftIntensity ) )

        -- Green gets shifted anyway
        color.g = color.g - shift

        -- Choose whether red or blue shift
        local doRedShift = math.random() > 0.5 and true or false
        if doRedShift then
            color.b = color.b - shift
        else
            color.r = color.r - shift
        end
    end
    return color
end

return Star