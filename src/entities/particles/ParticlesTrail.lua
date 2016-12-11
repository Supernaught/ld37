GameObject = require "src.entities.GameObject"
local ParticleSystem = require "src.entities.ParticleSystem"

local ParticlesPlayerDie = ParticleSystem:extend()
local assets =  require "src.assets"

function ParticlesPlayerDie:new(x, y)
	ParticlesPlayerDie.super.new(self, x or push:getWidth()/2, y or push:getHeight()/2)
	self.name = "ParticlesPlayerDie"
	self.ParticlesPlayerDie = true
	self:setDrawLayer("playerParticles")

	self.ps = love.graphics.newParticleSystem(assets.white, 100)
	self.ps:setParticleLifetime(0.1, 0.5)
	self.ps:setDirection(4*3.14)
	self.ps:setSpread(3.14 * 10)
	self.ps:setAreaSpread('normal', 5, 2)
	-- self.ps:setLinearDamping(50)
	self.ps:setLinearAcceleration(0,-50,0,-100)
	self.ps:setSpin(0, 30)
	self.ps:setColors(82, 127, 57, 255)
	self.ps:setRotation(0, 2*3.14)
	self.ps:setInsertMode('random')
	self.ps:setSizes(1, 0)

	return self
end

function ParticlesPlayerDie:update(dt)
	self.ps:update(dt)
end

function ParticlesPlayerDie:draw()
	love.graphics.draw(self.ps, 0, 0, 0, 1, 1)
end

return ParticlesPlayerDie