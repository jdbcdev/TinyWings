
application:setKeepAwake(true)
application:setOrientation(Application.LANDSCAPE_LEFT)
application:setBackgroundColor(0xC6E2FF)

local width = application:getContentWidth()
local height = application:getContentHeight()

local maxKeyPoints = 20
local segmentWidth = 10
local keyPoints = {}

local texture = Texture.new("gfx/stone.png", true, {wrap = Texture.REPEAT})
local limitX = 0

-- First approach
function generateHills()
	
	local origin_point = {0, height}
	table.insert(keyPoints, origin_point)
	
	local x = 0
	local y = height * 0.5
	for i = 2, maxKeyPoints do
		keyPoints[i] = {x, y}
		x = x + width * 0.5
		y = math.random(height)
	end
	
	local last_point = keyPoints[#keyPoints]
	extra_point = {last_point[1], height}
	table.insert(keyPoints, extra_point)
	
	print("extra_point", extra_point[1], extra_point[2])
	
	limitX = extra_point[1]
end

-- More smooth mountains
function generateHillsSmooth()
	local origin_point = {0, height}
	table.insert(keyPoints, origin_point)
	
	local minDX = 200
	local minDY = 200
	local rangeDX = 80;
    local rangeDY = 40;
	
	local x = 0
	local y = height * 0.5
	
	local dy, ny;
	local sign = 1 -- +1 - going up, -1 - going  down
    local paddingTop = 20;
    local paddingBottom = 20;
	
	local i
	for i = 2, maxKeyPoints do
		keyPoints[i] = {x, y}
		
		x = x + math.random(rangeDX) + minDX
		while(true) do
			dy = math.random(rangeDY) + minDY
			ny = y + dy *sign
			if (ny < height-paddingTop and ny > paddingBottom) then
				break
			end
		end
		
		y = ny
		
		sign = -1 * sign
	end
	
	local last_point = keyPoints[#keyPoints]
	extra_point = {last_point[1], height}
	table.insert(keyPoints, extra_point)
	
	limitX = extra_point[1]	
end

-- Add some extra points for given p0, p1
function divideSegment(p0, p1, curve)
		
	local hSegments = math.floor((p1[1] - p0[1]) / segmentWidth)
	local dx = (p1[1] - p0[1]) / hSegments
	local ymid = (p0[2] + p1[2]) / 2
	local ampl = (p0[2] - p1[2]) / 2
	local da = math.pi / hSegments
	
	table.insert(curve, {p0[1], p0[2]})
		
	local a
	for a = 1, hSegments do
		local x = math.floor(p0[1] + a * dx)
		local y = math.floor(ymid + ampl * math.cos(da * a))

		table.insert(curve, {x, y})
	end
	
end

--generateHillsSmooth()

function debug()
	local debugDraw = b2.DebugDraw.new()
	b2World:setDebugDraw(debugDraw)
	stage:addChild(debugDraw)
end

-- Draw mountains and box2d shape
function drawTerrain()

	local shape = Shape.new()
	shape:setLineStyle(1)
	--shape:setFillStyle(Shape.SOLID, 0x99ff00, 0.5)
	shape:setFillStyle(Shape.TEXTURE, texture)
	stage:addChild(shape)
	
	generateHillsSmooth()
	
	local curve = {}
	local a

	for a=2, #keyPoints-1 do
		divideSegment(keyPoints[a], keyPoints[a+1], curve)
		--shape:setFillStyle(Shape.TEXTURE, texture)
	end

	local extra = {curve[#curve][1], height}
	table.insert(curve, extra)
	local origin = {0, height}
	table.insert(curve, origin)
	shape:drawPoly(curve)

	local vertices = {}
	local a
	for a=1, #curve do
		local x, y = unpack(curve[a])
		table.insert(vertices, x)
		table.insert(vertices, y)
	end
	
	b2World:createTerrain(shape, vertices)
	
	return shape
end

require "box2d"
b2World = b2.World.new(0, 10, true)

debug()
local shape = drawTerrain()


-- Move terrain from right to left
function onEnterFrame()

	local posX = shape:getX()
	--print(posX, limitX)
	
	if (posX < width -limitX) then	
		shape:removeEventListener(Event.ENTER_FRAME, onEnterFrame)
	else
		shape:setX(posX -2)
	end
end

shape:addEventListener(Event.ENTER_FRAME, onEnterFrame)
	

--[[
local shape = Shape.new()
stage:addChild(shape)
 
local points = { {100,100}, {200,100}, {200,200}, {150,250},{100,200} }
shape:drawPoly(points)
 
function onEnterFrame()
	for i,p in ipairs(points) do
		p[1] = p[1] + math.random(-20,20)/20
		p[2] = p[2] + math.random(-20,30)/20
	end
	shape:clear()
	shape:setLineStyle(3)
	shape:setFillStyle(Shape.SOLID, 0x0000cc, 0.5)
	shape:drawPoly(points)
end
 
shape:addEventListener(Event.ENTER_FRAME, onEnterFrame)
]]--