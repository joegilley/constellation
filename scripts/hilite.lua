local json = require("json")
local physics = require("physics")
local utility = require("scripts.utility")

-- Create the hilite object that will be returned
local hilite = {}

-- This table will keep track of the highlighted objects, and will be used as the key to pertinent highlighting information specific to that star
-- Table:
--      [star] -> hlInfo { 
--                  origX =         The star's originating location, before any changes have been made as a result of highlighting
--                  origY =         See above
--                  origGroup =     The star's originating DisplayGroup, for when we return it back to it's position
--                  remove =        A list of DisplayObject's that need to be cleaned up after we're done highlighting
--                  resetTimer =    A handle to the timer that will un-highlight this star, in case we want to cancel that action
--                }
hilite.highlighted = {}

-- This is the selection area when trying to highlight a star.  It will be used as the radius to a dynamic physics object to listen for any collisions
local MAX_HIT_DISTANCE = 30
-- This is the physics "Category" for the hilite selector, so that we can selectively collide with other objects.  In order to register to be hilite'd, your object will have to have this value OR'd into it's maskBits
local HILITE_CATEGORY_BIT = 2
-- This is the time in ms for the star to return to its starting position
local HILITE_TIME = 500
-- This is the DisplayGroup for all highlighted objects.  This would hopefully be processed AFTER any group that is being sampled, otherwise the Highlight object will be rendered underneath!
local HILITE_GROUP = display.newGroup()
-- This is the width of the Highlight box
-- Maybe want to step-scale this if the object is too big (TODO?)
local HILITE_SIZE = 75
-- This is the stroke size of the Highlight box's perimeter.  Will want to be changed to 1px later.
local HILITE_STROKE_SIZE = 3
-- This is the buffer between two Highlighted objects, so they don't get all squishy looking
local HILITE_GROUP_BUFFER = HILITE_SIZE * 0.25
-- This is a SUM'd total physical bounding box size
local HILITE_GROUP_SIZE = HILITE_SIZE + HILITE_STROKE_SIZE + HILITE_GROUP_BUFFER

-- Exposes the selector category bit for any class that wants to register for hits
hilite.HILITE_CATEGORY_BIT = HILITE_CATEGORY_BIT

-- Expose an initialization function that will register this hiliter with the runtime for listening
function hilite:init(expansion)
    hilite.expansion = expansion or 150
    Runtime:addEventListener( "touch", self )
end

-- The touch listener to create selector objects we registered in the init
function hilite:touch(event)
    -- We only process the touch event where the user lifted up 
    if event.phase == "ended" then
        print("Touched: ", ("[x: %d, y: %d]"):format(event.x, event.y))

        -- Create the selector where the touch let up
        local soi = display.newCircle(event.x, event.y, MAX_HIT_DISTANCE)
        -- And make sure its invisible to the user (alhpa = 0)
        soi:setFillColor( 0, 0, 0, 0)
        
        -- Immediately after this frame destroy this object
        timer.performWithDelay( 1, function () soi:removeSelf() end )
        -- The selector object has to be dynamic in order to register collision events with something, but we can make it a sensor so that it doesn't shove anything around!
        -- The filter is set up to limit what we collide with and allow other physical objects to ignore this by default
        physics.addBody( soi, "dynamic", { isSensor = true, filter = {categoryBits = HILITE_CATEGORY_BIT, maskBits = 1} } )
        soi:addEventListener( "collision", self )
    end
end

-- A listener function to react to a collision event created from the selector
function hilite:collision(collision)
    -- print("Collision with: ", ("[name: %s, x: %d, y: %d]"):format(collision.other.name or "Unknown", collision.other.x, collision.other.y))
    -- We're only going to highlight stuff we've not highlighted already, duh
    if not self.highlighted[collision.other] then
        -- Highlight the object, and report where we clicked from
        self:highlight(collision.other, collision.target.x, collision.target.y)
    end
end

function hilite:highlight(star, referenceX, referenceY)
    -- Early out just in case. Maybe remove? Probably not.
    if self.highlighted[star] then return end
    print ("Highlighting object: ", ("[name: %s, x: %d, y: %d]"):format(star.name or "Unknown", star.x, star.y))

    -- Set up the table to hold the highlighting pertinents
    local hlInfo = { origX = star.x, origY = star.y }
    -- And register the star as highlighted, weee
    self.highlighted[star] = hlInfo

    -- This is essentially going to be an anonymous function so that we can do physics-y stuff.  
    -- According to SDK, if we try to do physics-y stuff while INSIDE of a collision event (which we are), the Box2D engine will crash!
    local function doHighlight()
        -- Set up the list of things we'll have to collect up later
        hlInfo.remove = {}

        -- Debugging stuff for displaying lines, doesn't work anymore :T
        -- local hlLine = display.newLine( HILITE_GROUP, referenceX, referenceY, star.x, star.y)
        -- table.insert(hlInfo.remove, hlLine)
        -- hlLine:setStrokeColor( 0.4 )
        -- hlLine.strokeWidth = 3
        -- hlInfo.line = hlLine

        -- This is the anchor to which we'll attach some hingy bar joint things so that our highlighted objects have something to rotate around.  This is where the user tapped btw
        local anchor = display.newRect(HILITE_GROUP, referenceX, referenceY, 1, 1)
        table.insert(hlInfo.remove, anchor)     -- Remember to deleter yo stuff
        anchor:setFillColor( 0, 0, 0, 0 )       -- Our anchor is invisible for now.. Maybe for eye candy we can put something here...
        physics.addBody( anchor, "static", { filter = { categoryBits = 4, maskBits = 0 } } )

        -- This is a handy little container that we can put our box thing in and our star to show off
        local hlGroup = display.newContainer( HILITE_GROUP, HILITE_GROUP_SIZE, HILITE_GROUP_SIZE )
        table.insert(hlInfo.remove, hlGroup)    -- Still gotta delete it later, though :(
        hlGroup:translate(star.x, star.y)       -- We want it to start of from where the star was, so we get a cool explody look 
        -- Our filter is set up here to ONLY collide with itself.  This way it won't get picked up by our selector (bc of other reasons too)
        physics.addBody( hlGroup, "dynamic", { density = 5, filter = { categoryBits = 4, maskBits = 4 } } )

        -- The background is the color parts, pretty standard stuff 
        local hlBackground = display.newRect( hlGroup, 0, 0, HILITE_SIZE, HILITE_SIZE )
        hlBackground:setFillColor( 0, 1.0, 0, 0.1)
        hlBackground:setStrokeColor( 0, 1.0, 0, 1.0 )
        hlBackground.strokeWidth = HILITE_STROKE_SIZE

        -- The joint is a hard distance joint so we don't get any oscillations
        local joint = physics.newJoint( "distance", anchor, hlGroup, anchor.x, anchor.y, hlGroup.x, hlGroup.y)
        joint.length = self.expansion

        -- The object needs to be relocated to 0,0 which is centered in the container we're about to add it to.
        star.x, star.y = 0, 0

        -- Save the object's original display group so we can be good borrowers, then steal it. ha
        hlInfo.origGroup = star.parent
        hlGroup:insert(star)

        -- This will lock the rotation of the group object so that it will always be upright for the user's pleasure
        hlGroup.isFixedRotation = true

        -- Create and save the reset timer to put it back after 5 seconds of nothing happening
        hlInfo.resetTimer = timer.performWithDelay( 5000, function() self:reset(star) end)

        -- Take control of taps so that we don't highlight stuff underneath.  These will be hooked into later to do "stuff" with the objects.
        hlGroup:addEventListener( "tap", function() print("Tapped " .. star.name); return true end )
        hlGroup:addEventListener( "touch", function () return true end )
    end

    -- Do the thing we're supposed to do at a randomly short interval to prevent it from looking too hacky
    timer.performWithDelay(math.random(0, 100), function() doHighlight() end)
end

-- This will reset the highlighted object back to its original state and do some clean ups, too.
function hilite:reset(star)
    -- Just to be sure...should never actually be a prob
    if self.highlighted[star] then
        local hlInfo = self.highlighted[star]
        -- tween our way back, our objects aren't old enough to find their own way :T
        local tween = {
            time = HILITE_TIME,
            x = hlInfo.origX,
            y = hlInfo.origY,
            -- Just a cute little return slope
            transition = easing.outBack,
            -- After we're all done, take this star out of the running, allowing it to be highlighted all over again
            -- We do this so it doesn't get highlighted DURING our way back, messing up the objects actual position.
            -- There are other ways to do this, but this is clean and assured.
            onComplete = function() self.highlighted[star] = nil end,
        }

        -- We want the object's starting position globally (this will only work if the parent it belongs to is not translated itself TODO!), not its old centered 0,0 location
        star.x, star.y = star:localToContent( star.x, star.y )

        -- Put it baaack
        hlInfo.origGroup:insert(star)

        -- And remove all the things we promised we would.
        -- Probably should check for existance of this method...maybe TODO?
        for _, v in ipairs(hlInfo.remove) do
            v:removeSelf( )
        end

        -- We only wait a little bit to start because its dumb and takes a little while for the textures to fall off-screen.
        -- If we did this immediately, the objects would move but the highlight box wouldn't, looking kind of wrong.
        timer.performWithDelay( 100, function () transition.to( star, tween ) end )
    end
end

return hilite