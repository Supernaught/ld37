-- play state

playstate = {}

-- libs
local HClib = require "lib.hc"
local Camera = require "lib.hump.camera"
local sti = require "lib.sti"
local lume = require "lib.lume"

-- entities
local Player = require "src.entities.Player"
local Explosion = require "src.entities.Explosion"
local Enemy = require "src.entities.Enemy"
local GrassAnimation = require "src.entities.GrassAnimation"

local player, player2
local scores = {}
scores[1] = 0
scores[2] = 0

respawnAreas = {}

HC = nil

function playstate:init()
	HC = HClib.new(150)

	-- map = sti("maps/plain.lua")
	-- map = sti("maps/plain2.lua")
	map = sti("maps/test_24.lua")

	-- get respawn areas
	for k, respawnPoint in pairs(map.layers['respawns'].objects) do
		table.insert(respawnAreas, {x = respawnPoint.x, y = respawnPoint.y})
	end

	self.world = tiny.world()
	world = self.world

	-- spawn players
	local respawnPoint = lume.randomchoice(respawnAreas)
	local respawnPoint2 = lume.randomchoice(respawnAreas)

	player = Player(respawnPoint.x, respawnPoint.y, 1)
	player2 = Player(respawnPoint2.x, respawnPoint2.y, 2, true)

	camera = Camera(0, 0, 1)

	enemy = Enemy(10,10)
	enemy.moveTowardsTarget = true
	enemy.targetPos = {x = push:getWidth()/2, y = push:getHeight()/2}
	enemy.moveTargetSpeed = 20

	self.world:add(
		require("src.systems.BGColorSystem")(238,240,210),
		require("src.systems.UpdateSystem")(),
		require("src.systems.DrawSystem")(),
		require("src.systems.MoveTowardsTargetSystem")(),
		require("src.systems.DrawSystem")("playerParticles"),
		require("src.systems.MovableSystem")(),
		require("src.systems.CollisionSystem")(),
		require("src.systems.SpriteSystem")(),
		require("src.systems.SpriteSystem")("player"),
		require("src.systems.SpriteSystem")("grassAnims"),
		require("src.systems.DrawUISystem")("hudForeground"),
		-- enemy,
		player,
		player2
		-- Explosion(10,10)
	)

	colliders = {}

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
		col = HC:rectangle(object.x, object.y, object.width, object.height)
		col.isSolid = true
		table.insert(colliders, col)
	end

	for y,row in pairs(map.layers['animations'].data) do
		for x,tile in pairs(row) do
			self.world:add(GrassAnimation((x-1) * reg.T_SIZE, (y-1) * reg.T_SIZE, tile.id))
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
	if k == reg.controls[1].jump then
		player:jump()
	elseif k == reg.controls[1].attack then
		player:attack()
	elseif k == reg.controls[1].roll then
		player:roll()
	elseif k == reg.controls[2].jump then
		player2:jump()
	elseif k == reg.controls[2].attack then
		player2:attack()
	elseif k == reg.controls[2].roll then
		player2:roll()
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

	love.graphics.setColor(0,0,0)
	love.graphics.print("Playstate.lua\nFPS: " .. love.timer.getFPS() .. "\nEntities: " .. world:getEntityCount(), 20, 20)
	love.graphics.print(player.movable.velocity.x, 20, 80)
	love.graphics.print("PLAYER 1: " .. scores[1], 20, 100)
	love.graphics.print("PLAYER 2: " .. scores[2], 20, 120)
	love.graphics.setColor(255,255,255,255)
end

function playstate:playerScored(playerNum)
	scores[playerNum] = scores[playerNum] + 1
end

function playstate:joystickaxis(j, axis, value)	
	if axis == 1 then
		player2.gamepadAxis.x = value
	elseif axis == 2 then
		player2.gamepadAxis.y = value
	elseif axis == 6 then
		player2.gamepadAxis.rt = value
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

function playstate.respawnPlayer(playerNum)
	local respawnPoint = lume.randomchoice(respawnAreas)

	if playerNum == 1 then
		player:respawn(respawnPoint.x, respawnPoint.y)
		-- player = Player(respawnPoint.x, respawnPoint.y, 1)
		-- playstate.world:add(player)
	else
		player2:respawn(respawnPoint.x, respawnPoint.y)
		-- player2 = Player(respawnPoint.x, respawnPoint.y, 2, true)
		-- playstate.world:add(player2)
	end
end

return playstate
