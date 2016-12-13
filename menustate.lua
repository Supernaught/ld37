menustate = {}

local flux = require "lib.flux"
local UIText = require "src.entities.UIText"
local UIImage = require "src.entities.UIImage"
local assets =  require "src.assets"

local title, pressToPlay
local dir = 1

function menustate:enter()
	timeScale = 1
	timer.clear()
	
	local titleImage = UIImage(assets.title, "center", -90)

	local pressStart = UIImage(assets.pressstart, "center", push:getHeight() * 0.7)
	pressStart.blinking = true
	pressStart.blinkDelay = 0.5

	self.world = tiny.world(
		require("src.systems.BlinkingSystem")(),
		require("src.systems.BGColorSystem")(238,240,210),
		require("src.systems.DrawUISystem")("hudForeground"),
		titleImage,
		pressStart
	)

	flux.to(titleImage.pos, 1, {y = 80}):ease("expoout")
	world = self.world
end

function menustate:update(dt)
	flux.update(dt)
end

function menustate:keypressed(k)
	if k == 'space' or k == 'return' then
		Gamestate.switch(PlayState)
	end
end

function menustate:gamepadpressed(j, button)
	Gamestate.switch(PlayState)
end

return menustate