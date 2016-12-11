GameObject = require "src.entities.GameObject"
local ParticleSystem = require "src.entities.ParticleSystem"

local ParticlesJump = ParticleSystem:extend()
local assets =  require "src.assets"

function ParticlesJump:new(x, y)
	ParticlesJump.super.new(self, x or push:getWidth()/2, y or push:getHeight()/2)
	self.name = "ParticlesJump"
	self.isParticlesJump = true
	self:setDrawLayer("playerParticles")
	self.ps = love.graphics.newParticleSystem(assets.white, 100)
	self.ps:setParticleLifetime(0.1, 0.5)
	-- self.ps:setDirection(4*3.14)
	-- self.ps:setSpread(3.14 * 10)
	self.ps:setAreaSpread('normal', 3, 1)
	-- self.ps:setLinearDamping(50)
	self.ps:setLinearAcceleration(-100,0,100,-50)
	self.ps:setColors(200, 200, 200, 200)
	self.ps:setRotation(0, 2*3.14)
	self.ps:setInsertMode('random')
	self.ps:setSizes(1, 0)

	return self
end

function ParticlesJump:update(dt)
	self.ps:update(dt)
end

function ParticlesJump:draw()
	love.graphics.draw(self.ps, 0, 0, 0, 1, 1)
end

return ParticlesJump