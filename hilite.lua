local json = require("json")
local physics = require("physics")
local utility = require("utility")

local hilite = {}
hilite.highlighted = {}

local MAX_HIT_DISTANCE = 30
local HILITE_CATEGORY_BIT = 2
local HILITE_TIME = 500
local HILITE_GROUP = display.newGroup()
local HILITE_SIZE = 75
local HILITE_STROKE_SIZE = 3
local HILITE_GROUP_BUFFER = HILITE_SIZE * 0.25
local HILITE_GROUP_SIZE = HILITE_SIZE + HILITE_STROKE_SIZE + HILITE_GROUP_BUFFER

hilite.HILITE_CATEGORY_BIT = HILITE_CATEGORY_BIT

function hilite:init(expansion)
    hilite.expansion = expansion or 150
    Runtime:addEventListener( "touch", self )
end

function hilite:collision(collision)
    -- print("Collision with: ", ("[name: %s, x: %d, y: %d]"):format(collision.other.name or "Unknown", collision.other.x, collision.other.y))
    self:highlight(collision.other, collision.target.x, collision.target.y)
end

function hilite:touch(event)
    if event.phase == "ended" then
        print("Touched: ", ("[x: %d, y: %d]"):format(event.x, event.y))

        local soi = display.newCircle(event.x, event.y, 30)
        soi:setFillColor( 0, 0, 0, 0)
        
        -- Immediately after this frame destroy this object
        timer.performWithDelay( 1, function () soi:removeSelf() end )
        physics.addBody( soi, "dynamic", { filter = {categoryBits = HILITE_CATEGORY_BIT, maskBits = 1} } )
        soi:addEventListener( "collision", hilite )
    end
end

function hilite:highlight(star, referenceX, referenceY)
    if self.highlighted[star] then return end
    print ("Highlighted object: ", ("[name: %s, x: %d, y: %d]"):format(star.name or "Unknown", star.x, star.y))

    local hlInfo = { origX = star.x, origY = star.y }
    self.highlighted[star] = hlInfo
    star.origX, star.origY = star.x, star.y

    local function doHighlight()
        hlInfo.remove = {}

        -- local hlLine = display.newLine( HILITE_GROUP, referenceX, referenceY, star.x, star.y)
        -- table.insert(hlInfo.remove, hlLine)
        -- hlLine:setStrokeColor( 0.4 )
        -- hlLine.strokeWidth = 3
        -- hlInfo.line = hlLine

        local anchor = display.newRect(HILITE_GROUP, referenceX, referenceY, 1, 1)
        table.insert(hlInfo.remove, anchor)
        anchor:setFillColor( 0, 0, 0, 0 )
        physics.addBody(anchor, "static")

        local hlGroup = display.newContainer( HILITE_GROUP, HILITE_GROUP_SIZE, HILITE_GROUP_SIZE )
        table.insert(hlInfo.remove, hlGroup)
        hlGroup:translate(star.x, star.y)
        physics.addBody( hlGroup, "dynamic", { density = 5, filter = { categoryBits = 4, maskBits = 4 } } )

        local hlBackground = display.newRect( hlGroup, 0, 0, HILITE_SIZE, HILITE_SIZE )
        hlBackground:setFillColor( 0, 1.0, 0, 0.1)
        hlBackground:setStrokeColor( 0, 1.0, 0, 1.0 )
        hlBackground.strokeWidth = HILITE_STROKE_SIZE

        local joint = physics.newJoint( "distance", anchor, hlGroup, anchor.x, anchor.y, hlGroup.x, hlGroup.y)
        -- joint.dampingRatio = 1.0
        -- joint.frequency = 0.4
        joint.length = self.expansion

        star.x, star.y = 0, 0

        hlInfo.origGroup = star.parent
        hlGroup:insert(star)

        hlGroup.isFixedRotation = true

        hlGroup:addEventListener( "tap", function() print("Tapped " .. star.name); return true end )
        hlGroup:addEventListener( "touch", function () return true end )

        hlInfo.resetTimer = timer.performWithDelay( 5000, function() self:reset(star) end)
    end

    timer.performWithDelay(math.random(0, 100), function() doHighlight() end)
end

function hilite:reset(star)
    if self.highlighted[star] then
        local hlInfo = self.highlighted[star]
        local tween = {
            time = HILITE_TIME,
            x = hlInfo.origX,
            y = hlInfo.origY,
            transition = easing.outBack,
            onComplete = function() self.highlighted[star] = nil end,
        }

        star.x, star.y = star:localToContent( star.x, star.y )

        hlInfo.origGroup:insert(star)

        for _, v in ipairs(hlInfo.remove) do
            v:removeSelf( )
        end

        timer.performWithDelay( 100, function () transition.to( star, tween ) end )
    end
end

function hilite:enterFrame(event) 

end

return hilite