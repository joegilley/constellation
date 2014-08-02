local proxy = require "proxy"

-- declare my ship object
local ship = proxy.get ( display.newImage( "sprites/drone.png" ) )

-- function init ship
function ship:init() 

	print( 'ship init' )

	-- self = proxy.get( display.newImage( "sprites/drone.png" ) )
	self.x = math.random( display.contentWidth )
	self.y = self.contentHeight
	self.targetRotation = 300

	Runtime:addEventListener( "enterFrame", ship )

end


--listener function for enterFrame event

function ship:enterFrame( event )

   self:translate( 0, 1 )    -- move ship 1pt down on every frame

   -- move ship above top of screen when it goes below the screen
	if self.y > display.contentHeight then
		self.y = -self.contentHeight
	end

	local turnSpeed = 0.001
	self.rotation = self.rotation + turnSpeed * (self.targetRotation - self.rotation)
	print(self.rotation)
end


-- assign the above function as an "enterFrame" listener
	-- Runtime:addEventListener( "enterFrame", ship )

return ship