-- debug logging:
print ("Scale factor: ", display.pixelWidth / display.actualContentWidth )

-- end debug logging

-- set up
local Star = require("star")
local physics = require("physics")
local widget = require("widget")

display.setStatusBar( display.HiddenStatusBar )
physics.start()

local initGUI, initStars, toggleDebug, start, processTap, tapCollision

local stars = {}

function initStars()
    local starGroup = display.newGroup( )
    local numStars = math.random(100, 500)
    for i=1, numStars do
        stars[i] = Star:new()
        stars[i]:init()
    end
    print( "Generated " .. #stars .. " stars" )
end

function initGUI()
    local debugButton = widget.newButton( {
        top = 20,
        left = 20,
        label = "D",
        labelAlign = "center",
        labelColor = { default = { 0.62, 0.07, 0.04 }},
        labelXOffset = 8,
        labelYOffset = -7,
        font = "Erbos Draco 1st Open NBP",
        fontSize = 40,
        onEvent = toggleDebug,
        emboss = true,
        shape = "roundedRect",
        width = 50,
        height = 50,
        cornerRadius = 5,
        fillColor = {
            default = { 0.6, 0.6, 0.6 },
            over = { 0.4, 0.4, 0.4 },
        },
    } )
    debugButton:addEventListener( "tap", toggleDebug )
end

function start() 
    initStars()
    initGUI()
end

function processTap(event)
    if event.phase == "ended" then
        local soi = display.newCircle(event.x, event.y, 30)
        timer.performWithDelay( 200, function () soi:removeSelf() end )
        physics.addBody( soi, "static", { isSensor = true } )
        soi:addEventListener( "collision", tapCollision )
    end
end

function tapCollision(collision) 
    print( collision.phase )
end

local isDebug = false
function toggleDebug(event)
    if event.phase == "ended" then
        isDebug = not isDebug

        if isDebug then
            physics.setDrawMode( "hybrid" )
        else
            physics.setDrawMode( "normal" )
        end
    end
    return true
end

local function main() 
    local font = "Erbos Draco 1st Open NBP"
    --local font = "HelveticaNeue-Light"
    local helloWordText = display.newText( "hello", display.contentWidth / 2, display.contentHeight / 2 - 25, font, 60)
    timer.performWithDelay( 1000, function() display.remove( helloWordText ); start() end )

    Runtime:addEventListener( "touch", processTap )

end

main()