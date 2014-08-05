local json = require('json')
local Proxy = require('scripts.proxy')

local StarModule = {}

local STAR_STANDARD_SIZE = 2
local STAR_CATEGORY_BIT = 1
local STAR_COLLIDE_BITS = 2

local STAR_GROUP = display.newGroup()

StarModule.STAR_CATEGORY_BIT = STAR_CATEGORY_BIT
StarModule.STAR_COLLIDE_BITS = STAR_COLLIDE_BITS
StarModule.STAR_DISPLAY_GROUP = STAR_GROUP

local starCounter = 1

-- public methods
function StarModule.new ( )
    local star = Proxy.get(display.newRect(STAR_GROUP, -10, -10, STAR_STANDARD_SIZE, STAR_STANDARD_SIZE))
    star.color = {1, 1, 1}
    star.name = "Star-" .. starCounter
    starCounter = starCounter + 1
    
    local getStarColor, randomFlickerTimer

    function star:init( vals )
        vals = vals or {}

        self.name = vals.name or self.name
        self.x = vals.x or self.x
        self.y = vals.y or self.y

        self.width = vals.width or vals.size or self.width
        self.height = vals.height or vals.size or self.height

        self.color = vals.color or getStarColor(self.color, 2, 1.0, 0.7)

        randomFlickerTimer(self)
        self:setFillColor( self.color[1],  self.color[2], self.color[3] )
        physics.addBody( self, "static", { isSensor = true, filter = { categoryBits = STAR_CATEGORY_BIT, maskBits = STAR_COLLIDE_BITS } } )
        self:addEventListener( "enterFrame", self )
    end

    function star:flicker(intensity, duration)
        local intensity = intensity or 0.9
        local duration = duration or 100
        self:setFillColor( self.color[1]*intensity, self.color[2]*intensity, self.color[3]*intensity )
        timer.performWithDelay( duration, function() self:setFillColor( self.color[1], self.color[2], self.color[3] ) end )
    end

    function randomFlickerTimer (star)
        local randomDelay = math.random(0, 120000)
        timer.performWithDelay( randomDelay, function()
            star:flicker(0.6, 75)
            randomFlickerTimer(star)
        end)
    end

    function getStarColor(initialColor, shiftProbabilityPower, shiftIntensity, shiftThreshold)
        -- Do a shallow copy so we don't mess up shared tables
        local color = {}
        color[1], color[2], color[3] = initialColor[1], initialColor[2], initialColor[3]

        -- These were trial and error estimated defaults
        local shiftProbabilityPower = shiftProbabilityPower or 2
        local shiftIntensity = shiftIntensity or 0.5
        local shiftThreshold = shiftThreshold or 0.7

        -- This will give a skew towards lower probabilities
        local doShift = math.random()^shiftProbabilityPower
        -- Only the upper 30% of the already skewed probabilities will pass
        if doShift > shiftThreshold then
            local shift = math.random() * math.min( 1, math.max( 0, math.random() * shiftIntensity ) )

            -- Green gets shifted anyway
            color[2] = color[2] - shift

            -- Choose whether red or blue shift
            local doRedShift = math.random() > 0.5 and true or false
            if doRedShift then
                color[3] = color[3] - shift
            else
                color[1] = color[1] - shift
            end
        end

        local yellowness = math.random(0, 3) / 10
        color[3] = math.max(0, color[3] - yellowness)
        return color
    end

    return star
end

return StarModule