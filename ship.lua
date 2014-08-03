local proxy = require "proxy"
local physics = require "physics"

-- declare my ship object
local ship = proxy.get ( display.newContainer( 150, 200 ) )

-- function init ship
function ship:init() 
	print( 'ship init' )

	-- body is 150x140 
	local body = display.newImage( "sprites/body.png" )
	body.x = 0;
	body.y = 0;
	self:insert( body, false ) -- insert body into container

	-- engine is 40x110
	local engine = display.newImage( "sprites/engine.png" )
	engine.x = 10;
	engine.y = 100;
	self:insert( engine, false ) -- insert engine into container
	--engine.x = 110;
	--self:insert( engine, false ) -- insert engine into container

	-- self = proxy.get( display.newImage( "sprites/drone.png" ) )
	self.x = math.random( display.contentWidth )
	self.y = self.contentHeight
	self.targetRotation = 300

	self:scale(0.5,0.5)

	physics.addBody( self, "kinematic" )
	Runtime:addEventListener( "enterFrame", ship )

end


function ship:setScale( scale ) 
    self:scale( scale, scale )
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