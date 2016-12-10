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

local player, player2
local uiScore
local score = 0
local respawnAreas = {}

HC = nil

function playstate:init()
	HC = HClib.new(150)

	map = sti("maps/test_24.lua")

	self.world = tiny.world()
	world = self.world

	player = Player(nil, nil, 1)
	player2 = Player(200, nil, 2)

	camera = Camera(0, 0, 1)

	enemy = Enemy(10,10)
	enemy.moveTowardsTarget = true
	enemy.targetPos = {x = push:getWidth()/2, y = push:getHeight()/2}
	enemy.moveTargetSpeed = 20

	self.world:add(
		require("src.systems.BGColorSystem")(200,220,250),
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
		player,
		player2
		-- Explosion(10,10)
	)

	colliders = {}

	for k, respawnPoint in pairs(map.layers['respawns'].objects) do
		table.insert(respawnAreas, {x = respawnPoint.x, y = respawnPoint.y})
		-- for i, obj in pairs(layer.objects) do
		-- 	print(i)
		-- end
	end

	-- for k, layer in pairs(map.layers) do
	-- 	log.trace(k .. "---" .. layer.name)
	-- 	if layer.objects then
	-- 		for i, obj in pairs(layer.objects) do
	-- 			for k, d in pairs(obj) do
	-- 				print(k .. ": " .. tostring(d))
	-- 			end
	-- 		end
	-- 	end
	-- end

	for k, object in pairs(map.layers['collisions'].objects) do
		col = HC:rectangle((object.x-1), (object.y-1), object.width, object.height)
		col.isSolid = true
		table.insert(colliders, col)
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
	if k == reg.controls[1].jump then
		player:jump()
	elseif k == reg.controls[2].jump then
		player2:jump()
	elseif k == reg.controls[1].attack then
		player:attack()
	elseif k == reg.controls[2].attack then
		player2:attack()
	end

	-- toggle draw collisions
	if k == '`' then
		reg.DEBUG_COLLISIONS = not reg.DEBUG_COLLISIONS
	end
end

function playstate:update(dt)
	map:update(dt)
end

function playstate:draw()
	screen:apply()
	push:apply("start")
	map:draw()

	if reg.DEBUG_COLLISIONS then
		for i,c in pairs(colliders) do
			c:draw()
		end
	end

	push:apply("end")

	love.graphics.print("Playstate.lua\nFPS: " .. love.timer.getFPS() .. "\nEntities: " .. world:getEntityCount(), 20, 20)
	love.graphics.print(player.movable.velocity.x, 20, 80)
end

function playstate:joystickaxis(j, axis, value)
	if axis == 1 then
		player2.gamepadAxis.x = value
	elseif axis == 2 then
		player2.gamepadAxis.y = value
	end
end

function playstate:gamepadpressed(j, button)
	if button == 'a' then
		player2.gamepadAxis.jump = true
		player2:jump()
	elseif button == 'x' then
		player2.gamepadAxis.attack = true
		player2:attack()
	end
end

function playstate:gamepadreleased(j, button)
	if button == 'a' then
		player2.gamepadAxis.jump = false
	elseif button == 'x' then
		player2.gamepadAxis.attack = false
	end
end

return playstate