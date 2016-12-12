GameObject = require "src.entities.GameObject"
local ParticleSystem = require "src.entities.ParticleSystem"

local ParticlesTrail = ParticleSystem:extend()
local assets =  require "src.assets"

function ParticlesTrail:new(playerNum)
	ParticlesTrail.super.new(self, 0,0)
	self.name = "ParticlesTrail"
	self.isParticlesTrail = true
	self:setDrawLayer("playerParticles")

	-- self.ps = love.graphics.newParticleSystem(assets.white, 100)
	local sp = assets.playerDash[1]
	self.ps = love.graphics.newParticleSystem(assets.playerDash[playerNum], 100)
	self.ps:setParticleLifetime(0.1, 0.8)
	-- self.ps:setDirection(4*3.14)
	-- self.ps:setSpread(3.14 * 10)
	self.ps:setAreaSpread('normal', 2, 1)
	-- self.ps:setLinearDamping(50)
	-- self.ps:setLinearAcceleration(0,-50,0,-100)
	self.ps:setColors(
		200,
		200,
		200,
		225,

		200,
		200,
		200,
		0)

	table.insert(self.particleSystems, self.ps)
	
	self.ps:setRotation(0, 2*3.14)
	self.ps:setSizes(1, 0.5)

	return self
end

return ParticlesTrail