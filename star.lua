local Proxy = require('proxy')
local json = require('json')


local StarModule = {}

local STAR_STANDARD_SIZE = 2

local starDisplayGroup = display.newGroup()

-- public methods
function StarModule.new ( vals )
    local star = Proxy.get(display.newRect(starDisplayGroup, vals.x or -10, vals.y or -10, vals.size or STAR_STANDARD_SIZE, vals.size or STAR_STANDARD_SIZE))
    star.color = vals.color or {1, 1, 1}
    
    local setupShiftColor, randomFlickerTimer

    function star:init( vals )
        vals = vals or {}
        self.x = vals.x or math.random(0, display.contentWidth)
        self.y = vals.y or math.random(0, display.contentHeight)

        self.width = vals.width or (self.width + math.random(0, 3))
        self.height = vals.height or (self.height + math.random(0, 3))

        -- TODO vals.color needs to be shallow copied or it could reference multiple tables
        -- self.fill = vals.paint or setupShiftColor(self.fill, 2, 0.5)

        randomFlickerTimer(self)
        self.color = setupShiftColor(self.color, 2, 1.0, 0.7)
        self:setFillColor( self.color[1],  self.color[2], self.color[3] )
        physics.addBody( self, "static", { isSensor = true } )
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

    function setupShiftColor(initialColor, shiftProbabilityPower, shiftIntensity, shiftThreshold)
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
        return color
    end

    return star
end

return StarModule