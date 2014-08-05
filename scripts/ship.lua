local physics = require "physics"
local proxy = require "scripts.proxy"

-- declare my ship object
local ship = proxy.get ( display.newContainer( 300, 300 ) )

-- function init ship
function ship:init() 
	print( 'ship init' )

	-- get the design
	local design = buildShip()

    -- define some vars for math cuz math is hard
	local limits = 11
    local part_scale = 25;

    -- because everything goes from the center
    local origin_x = 1 - ( ( limits * 25 ) / 2 )
    local origin_y = origin_x

    -- my list of tiles
    local part_tiles = {}

    -- dont know
    local part

    for y, row in pairs(design) do
	    for x, col in pairs(row) do

	    	-- create an index for the tiles table
	    	index = ( x * limits ) + y

	    	if col == 1 then
				part_tiles[index] = display.newImage( "sprites/parts/tile.png" )
	    	end

	    	if col == 2 then
				part_tiles[index] = display.newImage( "sprites/parts/engine.png" )
	    	end

	    	if col == 3 then
				part_tiles[index] = display.newImage( "sprites/parts/marker.png" )
	    	end

	    	if part_tiles[index] then
				part_tiles[index].x = origin_x + ( ( x - 1 ) * part_scale ) + ( part_tiles[index].width / 2 )
    			part_tiles[index].y = origin_y + ( ( y - 1 ) * part_scale ) + ( part_tiles[index].height / 2 )
    			self:insert( part_tiles[index], false )
    		end
	    end
    end

   
	self.x = math.random( display.contentWidth )
	self.y = self.contentHeight
	self.targetRotation = 300

	self:scale(0.5,0.5)

	physics.addBody( self, "kinematic" )
	Runtime:addEventListener( "enterFrame", ship )

end

function buildShip() 
    design = {}

	design[2] = {}
	design[2][5] = 1
	design[2][6] = 1
	design[2][7] = 1

	design[3] = {}
	design[3][4] = 1
	design[3][5] = 1
	design[3][6] = 1
	design[3][7] = 1
	design[3][8] = 1

	design[4] = {}
	design[4][4] = 1
	design[4][5] = 1
	design[4][6] = 1
	design[4][7] = 1
	design[4][8] = 1

	design[5] = {}
	design[5][4] = 1
	design[5][5] = 1
	design[5][6] = 1
	design[5][7] = 1
	design[5][8] = 1

	design[6] = {}
	design[6][5] = 1
	design[6][6] = 1
	design[6][7] = 1

	design[7] = {}
	design[7][5] = 1
	design[7][6] = 1
	design[7][7] = 1

	design[8] = {}
	design[8][4] = 2
	design[8][6] = 1
	design[8][7] = 2

	design[9] = {}
	design[9][6] = 1

	design[10] = {}
	design[10][6] = 1

	design[1] = {}
	design[1][1] = 3
	design[1][11] = 3
	design[11] = {}
	design[11][1] = 3
	design[11][11] = 3


    return design;
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
end


-- assign the above function as an "enterFrame" listener
	-- Runtime:addEventListener( "enterFrame", ship )

return ship