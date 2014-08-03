local json = require("json")
local physics = require("physics")
local utility = require("utility")

local hilite = {}

local MAX_HIT_DISTANCE = 30
local HILITE_TIME = 500
local HILITE_GROUP = display.newGroup()
local HILITE_SIZE = 75
local HILITE_STROKE_SIZE = 2
local HILITE_GROUP_BUFFER = HILITE_SIZE * 0.25
local HILITE_GROUP_SIZE = HILITE_SIZE + HILITE_STROKE_SIZE + HILITE_GROUP_BUFFER

function hilite:init(expansion)
    self.expansion = expansion or 75
    -- performWithDelay( 10, function() Runtime:addEventListener("enterFrame", self) end)
end


hilite.highlighted = {}
function hilite:highlight(star, referenceX, referenceY)
    if self.highlighted[star] then return end
    
    local hlInfo = { origX = star.x, origY = star.y }
    self.highlighted[star] = hlInfo
    star.origX, star.origY = star.x, star.y

    local adjacent, opposite = (star.x - referenceX), (star.y - referenceY)

    local angle = math.atan2( opposite, adjacent )
    local hypotScale = MAX_HIT_DISTANCE / math.sqrt( opposite ^ 2 + adjacent ^ 2 )
    
    local deltaX = adjacent + self.expansion * math.cos( angle ) --* hypotScale
    local deltaY = opposite + self.expansion * math.sin( angle ) --* hypotScale

    local function doHighlight()
        local hlLine = display.newLine( HILITE_GROUP, referenceX, referenceY, star.x, star.y)
        hlLine:setStrokeColor( 0.4 )
        hlLine.strokeWidth = 3
        hlInfo.line = hlLine

        local hlGroup = display.newContainer( HILITE_GROUP, HILITE_GROUP_SIZE, HILITE_GROUP_SIZE )
        hlGroup:translate(star.x, star.y)

        local hlBackground = display.newRect( hlGroup, 0, 0, HILITE_SIZE, HILITE_SIZE )
        hlBackground:setFillColor( 0, 1.0, 0, 0.1)
        hlBackground:setStrokeColor( 0, 1.0, 0, 1.0 )
        hlBackground.strokeWidth = HILITE_STROKE_SIZE

        star.x, star.y = 0, 0

        hlInfo.origGroup = star.parent
        hlInfo.group = hlGroup
        hlGroup:insert(star)

        physics.addBody( hlGroup, "dynamic", { filter = { categoryBits = 4, maskBits = 4 } } )
        hlGroup.isFixedRotation = true

        timer.performWithDelay( 1000, function() self:reset(star) end)
    end

    local tween = {
        time = HILITE_TIME, 
        x=deltaX + star.x, 
        y=deltaY + star.y, 
        xScale = 5,
        yScale = 5,
        transition = easing.outBack,
        onComplete = doHighlight
    }
    -- print(json.encode(tween, {indent = true}))
    timer.performWithDelay(math.random(0, 500), function() doHighlight() end)


    -- timer.performWithDelay( 2000, function() 
    --         transition.moveTo( object, {
    --             time=HILITE_TIME, 
    --             x = config.origX, 
    --             y = config.origY, 
    --             xScale = 1, 
    --             yScale = 1,
    --             transition = easing.inBack} )
    --         table.remove(self.highlighting, object)
    --     end
    -- )

end

hilite.resetTimer = nil
function hilite:reset(star)
    if self.highlighted[star] then
        local hlInfo = self.highlighted[star]
        local tween = {
            time = HILITE_TIME,
            x = hlInfo.origX,
            y = hlInfo.origY,
            transition = easing.outBack,
        }

        star.x, star.y = star:localToContent( star.x, star.y )

        hlInfo.origGroup:insert(star)
        hlInfo.group:removeSelf( )
        hlInfo.line:removeSelf( )

        transition.to( star, tween )

        self.highlighted[star] = nil
    end
    -- for star, hlInfo in pairs(self.highlighted) do
    --     local tween = {
    --         time = HILITE_TIME,
    --         x = hlInfo.origX,
    --         y = hlInfo.origY,
    --         transition = easing.outBack,
    --     }

    --     star.x, star.y = star:localToContent( star.x, star.y )

    --     hlInfo.origGroup:insert(star)

    --     print()

    --     hlInfo.group:removeSelf()

    --     hlInfo.line:removeSelf()
        
    --     transition.to(star, tween)
    -- end
    -- self.highlighted = {}
    -- self.resetTimer = nil
end

function hilite:enterFrame(event) 

end

return hilite