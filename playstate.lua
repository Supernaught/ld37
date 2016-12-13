-- play state

playstate = {}

-- libs
local flux = require "lib.flux"
local HClib = require "lib.hc"
local Camera = require "lib.hump.camera"
local lume = require "lib.lume"

-- entities
local Player = require "src.entities.Player"
local Explosion = require "src.entities.Explosion"
local GrassAnimation = require "src.entities.GrassAnimation"
local WaterAnimation = require "src.entities.WaterAnimation"
local TileMap = require "src.entities.TileMap"
local UIText = require "src.entities.UIText"
local UIImage = require "src.entities.UIImage"
local assets =  require "src.assets"

local players = {}
local scores = {}
local isShowingGameOverHud = false

scoreUI = {}
timeUI = {}

scores[1] = 0
scores[2] = 0

respawnAreas = {}

HC = nil

function playstate:enter()
	timeScale = 1
	reg.gameTime = 0
	reg.gameOver = false
	reg.startPlay = false
	timer.clear()

	scores[1] = 0
	scores[2] = 0
	scoreUI[1] = 0
	scoreUI[2] = 0

	HC = HClib.new(150)

	tileMap = TileMap()

	-- get respawn areas
	for k, respawnPoint in pairs(tileMap.map.layers['respawns'].objects) do
		table.insert(respawnAreas, {x = respawnPoint.x, y = respawnPoint.y})
	end

	self.world = tiny.world()
	world = self.world

	-- spawn players
	local respawnPoint = lume.randomchoice(respawnAreas)
	local respawnPoint2 = lume.randomchoice(respawnAreas)

	players[1] = Player(24, 24 * 9, 1, true)
	players[2] = Player(24 * 22, 24 * 9, 2, true)

	camera = Camera(0, 0, 1)

	self.world:add(
		require("src.systems.BGColorSystem")(238,240,210),
		require("src.systems.UpdateSystem")(),
		require("src.systems.DrawSystem")("jumpParticles"),
		require("src.systems.DrawSystem")(),
		require("src.systems.MoveTowardsTargetSystem")(),
		require("src.systems.TileMapSystem")(),
		require("src.systems.DrawSystem")("playerParticles"),
		require("src.systems.MovableSystem")(),
		require("src.systems.CollisionSystem")(),
		require("src.systems.SpriteSystem")(),
		require("src.systems.SpriteSystem")("player"),
		require("src.systems.SpriteSystem")("grassAnims"),
		require("src.systems.SpriteSystem")("waterAnims"),
		require("src.systems.DrawUISystem")("hudForeground"),
		tileMap,
		players[1],
		players[2]
	)

	colliders = {}

	-- add colliders
	for k, object in pairs(tileMap.map.layers['collisions'].objects) do
		col = HC:rectangle(object.x, object.y, object.width, object.height)
		col.isSolid = true
		table.insert(colliders, col)
	end

	-- add map border collisions
	leftWall = HC:rectangle(-reg.T_SIZE, 0, reg.T_SIZE, push:getHeight())
	leftWall.isSolid = true
	rightWall = HC:rectangle(push:getWidth(), 0, reg.T_SIZE, push:getHeight())
	rightWall.isSolid = true
	-- topWall = HC:rectangle(0, -24, push:getWidth(), 24)
	-- topWall.isSolid = true

	-- add grass animations
	for y,row in pairs(tileMap.map.layers['animations'].data) do
		for x,tile in pairs(row) do
			if tile.id == 10 or tile.id == 20 or tile.id == 30 then
				self.world:add(GrassAnimation((x-1) * reg.T_SIZE, (y-1) * reg.T_SIZE, tile.id))
			elseif tile.id == 50 then
				self.world:add(WaterAnimation((x-1) * reg.T_SIZE, (y-1) * reg.T_SIZE, tile.id))
			end
		end
	end

	-- add colliders to tiles in "solid" layer
	for y,row in pairs(tileMap.map.layers["solid"].data) do
		for x,tile in pairs(row) do
			col = HC:rectangle((x-1) * tile.width, (y-1) * tile.height, tile.width, tile.height)
			col.isSolid = true
			table.insert(colliders, col)
		end
	end

	tileMap.map:removeLayer("collisions")

	self:setupHud()
	self:setupReadyFight()
end

function playstate:setupHud()
	local pad = 2
	local p1Portrait = UIImage(assets.hud1, pad, pad)
	local p2Portrait = UIImage(assets.hud2, push:getWidth() - assets.hud2:getWidth() - pad, pad)

	scoreUI[1] = UIText("0", 80, 12, 70, "center", nil, assets.font_sm)
	scoreUI[2] = UIText("0", 445, 12, 70, "center", nil, assets.font_sm)

	world:add(p1Portrait)
	world:add(p2Portrait)

	world:add(scoreUI[1])
	world:add(scoreUI[2])
end

function playstate:setupReadyFight()
	local readyText = UIImage(assets.ready, "center", -50)
	local fightText = UIImage(assets.fight, "center", push:getHeight()/2 - 20)

	world:add(readyText)

	flux.to(readyText.pos, 1, {y = push:getHeight()/2 - 20}):ease("expoinout"):oncomplete(function()
		timer.after(0.5, function()
			world:remove(readyText)

			world:add(fightText)
			screen:setShake(10)
			screen:setRotation(0.1)
			timer.after(0.6, function()
				reg.startPlay = true
				world:remove(fightText)
			end)
		end)
	end)
end

function playstate:keypressed(k)
	if not reg.gameOver then
		if not reg.startPlay then return end

		if k == reg.controls[1].jump then
			players[1]:jump()
		elseif k == reg.controls[1].attack then
			players[1]:attack()
		elseif k == reg.controls[1].roll then
			players[1]:roll()
		elseif k == reg.controls[2].jump then
			players[2]:jump()
		elseif k == reg.controls[2].attack then
			players[2]:attack()
		elseif k == reg.controls[2].roll then
			players[2]:roll()
		end
	else
		if k == 'return' or k == 'space' then
			Gamestate.switch(MenuState)
		end

		if k == 'r' then
			Gamestate.switch(PlayState)
		end
	end

	if k == 'escape' then
		Gamestate.switch(MenuState)
	end

	-- toggle draw collisions
	if k == '`' then
		reg.DEBUG_COLLISIONS = not reg.DEBUG_COLLISIONS
	end
end

function playstate:update(dt)
	flux.update(dt)
end

function playstate:draw()
	screen:apply()
	push:apply("start")

	if reg.DEBUG_COLLISIONS then
		for i,c in pairs(colliders) do
			c:draw()
		end
	end
	push:apply("end")

	love.graphics.setColor(71,125,196)
	love.graphics.rectangle("fill", -100, push:getHeight() * 2 - 15, push:getWidth() * 4, 200)
	love.graphics.setColor(255,255,255,255)
end

function playstate:playerScored(playerNum) -- player num of scorer
	scores[playerNum] = scores[playerNum] + 1
	scoreUI[playerNum].text = scores[playerNum]

	print(scores[1], scores[2])

	if scores[playerNum] >= reg.MAX_SCORE then
		self:gameOver()
	end
end

function playstate:gameOver()
	screen:setShake(100)
	reg.gameOver = true
	timeScale = 0.2
	timer.after(3, function() timeScale = 1 end)
	timer.after(3.5, function() self.showGameOverHud() end)
end

function playstate:showGameOverHud()
	screen:setShake(15)
	-- screen:setRotation(0.1)

	isShowingGameOverHud = true

	local gameOverText = UIImage(assets.gameOver, "center", push:getHeight()/2 - 50)
	world:add(gameOverText)


	local winner = 1

	if scores[2] > scores[1] then
		winner = 2
	end

	timer.after(1, function()
		local playerWins = UIImage(assets.playerWin[winner], "center", push:getHeight()/2 + 10)
		screen:setShake(10)
		-- screen:setRotation(-0.05)
		world:add(playerWins)
	end)
end

function playstate:joystickaxis(j, axis, value)
	if reg.gameOver or not reg.startPlay then return end

	local gamepadId, gamepadInstanceId = j:getID()
	if axis == 1 then
		players[gamepadId].gamepadAxis.x = value
	elseif axis == 2 then
		players[gamepadId].gamepadAxis.y = value
	elseif axis == 6 then
		players[gamepadId].gamepadAxis.rt = value
	end
end

function playstate:keypressed(k)
	if not reg.gameOver then
		if not reg.startPlay then return end 
		
		if k == reg.controls[1].jump then
			players[1]:jump()
		elseif k == reg.controls[1].attack then
			players[1]:attack()
		elseif k == reg.controls[1].roll then
			players[1]:roll()
		elseif k == reg.controls[2].jump then
			players[2]:jump()
		elseif k == reg.controls[2].attack then
			players[2]:attack()
		elseif k == reg.controls[2].roll then
			players[2]:roll()
		end
	else
		if k == 'return' or k == 'space' then
			Gamestate.switch(MenuState)
		end

		if k == 'r' then
			Gamestate.switch(PlayState)
		end
	end

	if k == 'escape' then
		Gamestate.switch(MenuState)
	end

	-- toggle draw collisions
	if k == '`' then
		reg.DEBUG_COLLISIONS = not reg.DEBUG_COLLISIONS
	end
end

function playstate:gamepadpressed(j, button)
	local gamepadId, gamepadInstanceId = j:getID()

	-- UI gameover
	if reg.gameOver then
		if button == 'a' or button == 'start' then
			Gamestate.switch(MenuState)
			return
		end
	end

	if reg.gameOver or not reg.startPlay then return end

	-- gameplay
	if button == 'a' then
		players[gamepadId].gamepadAxis.jump = true
		players[gamepadId]:jump()
	elseif button == 'x' then
		players[gamepadId].gamepadAxis.attack = true
		players[gamepadId]:attack()
	end
end

function playstate:gamepadreleased(j, button)
	if reg.gameOver or not reg.startPlay then return end

	local gamepadId, gamepadInstanceId = j:getID()

	if button == 'a' then
		players[gamepadId].gamepadAxis.jump = false
	elseif button == 'x' then
		players[gamepadId].gamepadAxis.attack = false
	end
end

function playstate.respawnPlayer(playerNum)
	local respawnPoint = lume.randomchoice(respawnAreas)
	players[playerNum]:respawn(respawnPoint.x, respawnPoint.y)
end

return playstate
