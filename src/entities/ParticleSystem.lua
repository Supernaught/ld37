GameObject = require "src.entities.GameObject"

local ParticleSystem = GameObject:extend()
local assets =  require "src.assets"

function ParticleSystem:new(x, y)
	ParticleSystem.super.new(self, x or push:getWidth()/2, y or push:getHeight()/2)
	self.name = "ParticleSystem"
	self.isParticleSystem = true

	-- self.ps = love.graphics.newParticleSystem(assets.white, 100)
	self.particleSystems = {}
	return self
end

function ParticleSystem:update(dt)
	for i, ps in pairs(self.particleSystems) do
		ps:update(dt * timeScale)
	end
end

function ParticleSystem:draw()
	for i, ps in pairs(self.particleSystems) do
		love.graphics.draw(ps, 0, 0, 0, 1, 1)
	end
end

return ParticleSystem