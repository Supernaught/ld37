--
-- Animating static grass
-- by Alphonsus
--

local Grass = GameObject:extend()
local vector = require "lib.hump.vector"
local assets =  require "src.assets"

function Grass:new(x, y, tileId)
	Grass.super.new(self, x, y)
	self.name = "Grass"
	self.isGrass = true

	-- sprite/animation component
	self.sprite = assets.grass
	local g = anim8.newGrid(reg.T_SIZE, reg.T_SIZE, self.sprite:getWidth(), self.sprite:getHeight())

	row = 2

	if tileId == 20 then row = 3 end
	if tileId == 30 then row = 4 end

	self.animation = anim8.newAnimation(g('1-3', row), 0.17)

	self:setDrawLayer("grassAnims")

	return self
end

return Grass
