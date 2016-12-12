GameObject = require "src.entities.GameObject"
local ParticleSystem = require "src.entities.ParticleSystem"

local ParticlesPlayerDie = ParticleSystem:extend()
local assets =  require "src.assets"

local colors = {}
colors[1] = {
	c1 = { 163, 206, 39, 150, 163, 206, 39, 0 },
	c2 = { 68, 137, 26, 150, 68, 137, 26, 0, } ,
}

colors[2] = {
	c1 = {193, 39, 206, 150, 193, 39, 206, 0},
	c2 = {137, 26, 104, 150, 137, 26, 104, 0}
}


function ParticlesPlayerDie:new(x, y, playerNum)
	ParticlesPlayerDie.super.new(self, x or push:getWidth()/2, y or push:getHeight()/2)
	self.name = "ParticlesPlayerDie"
	self.isParticlesPlayerDie = true

	-- ps1
	self.ps = love.graphics.newParticleSystem(assets.white, 100)
	self.ps:setPosition(x, y)
	self.ps:setParticleLifetime(0.2, 1)
	self.ps:setDirection(4*3.14)
	self.ps:setSpread(3.14 * 10)
	self.ps:setAreaSpread('normal', 10, 15)
	self.ps:setLinearAcceleration(-30,-0,30,-30)
	self.ps:setSpin(0, 30)
	self.ps:setColors(colors[playerNum].c1)
	self.ps:setRotation(0, 2*3.14)
	self.ps:setInsertMode('random')
	self.ps:setSizes(2, 0)

	-- ps2
	self.ps2 = self.ps:clone()
	self.ps2:setAreaSpread('normal', 3, 4)
	self.ps:setLinearAcceleration(-10,-10,10,10)
	self.ps:setSizes(1, 0)
	self.ps2:setColors(colors[playerNum].c2)

	self.ps:emit(50)
	self.ps2:emit(10)

	table.insert(self.particleSystems, self.ps)
	table.insert(self.particleSystems, self.ps2)

	return self
end

return ParticlesPlayerDie