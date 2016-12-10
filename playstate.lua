-- play state

playstate = {}

-- libs
local HClib = require "lib.hc"
local Camera = require "lib.hump.camera"
local sti = require "lib.sti"

-- entities
local Player = require "src.entities.Player"
local Explosion = require "src.entities.Explosion"
local Enemy = require "src.entities.Enemy"

local player
local uiScore
local score = 0

HC = nil

function playstate:init()
	HC = HClib.new(150)

	map = sti("maps/test.lua")

	self.world = tiny.world()
	world = self.world

	player = Player()

	camera = Camera(0, 0, 1)

	enemy = Enemy(10,10)
	enemy.moveTowardsTarget = true
	enemy.targetPos = {x = push:getWidth()/2, y = push:getHeight()/2}
	enemy.moveTargetSpeed = 20

	self.world:add(
		require("src.systems.BGColorSystem")(20,0,0),
		require("src.systems.UpdateSystem")(),
		require("src.systems.DrawSystem")(),
		require("src.systems.MoveTowardsTargetSystem")(),
		require("src.systems.DrawSystem")("playerParticles"),
		require("src.systems.MovableSystem")(),
		require("src.systems.CollisionSystem")(),
		require("src.systems.SpriteSystem")(),
		require("src.systems.SpriteSystem")("player"),
		require("src.systems.DrawUISystem")("hudForeground"),
		-- enemy,
		player
		-- Explosion(10,10)
	)

	colliders = {}

	for k, object in pairs(map.objects) do
		if object.name == "collision" then
			col = HC:rectangle((object.x-1), (object.y-1), object.width, object.height)
			col.isSolid = true
			table.insert(colliders, col)
		end
	end

	-- add colliders to tiles in "solid" layer
	for y,row in pairs(map.layers["solid"].data) do
		for x,tile in pairs(row) do
			col = HC:rectangle((x-1) * tile.width, (y-1) * tile.height, tile.width, tile.height)
			col.isSolid = true
			table.insert(colliders, col)
		end
	end

	map:removeLayer("collisions")
end

function playstate:keypressed(k)
	if k == 'z' then
		player:jump()
	end
end

function playstate:update(dt)
	map:update(dt)
end

function playstate:draw()
	push:apply("start")
	map:draw()
	for i,c in pairs(colliders) do
		-- c:draw()
	end
	push:apply("end")

	love.graphics.print("Playstate.lua\nFPS: " .. love.timer.getFPS() .. "\nEntities: " .. world:getEntityCount(), 20, 20)
	love.graphics.print(player.movable.velocity.x, 20, 80)
end

return playstate