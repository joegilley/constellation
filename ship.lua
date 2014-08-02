local ship = display.newImage( "sprites/drone.png" )
ship.x = math.random( display.contentWidth )
ship.y = -ship.contentHeight
ship.targetRotation = 135

--listener function for enterFrame event
local function onEveryFrame( event )
   ship:translate( 0, 1 )    -- move ship 1pt down on every frame

   -- move ship above top of screen when it goes below the screen
   if ship.y > display.contentHeight then
      ship.y = -ship.contentHeight
   end

	local turnSpeed = 0.05
	ship.rotation = ship.rotation + turnSpeed * (ship.targetRotation - ship.rotation)
	print(ship.rotation)
end

-- assign the above function as an "enterFrame" listener
Runtime:addEventListener( "enterFrame", onEveryFrame )
