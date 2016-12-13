--
-- Animating static water
-- by Alphonsus
--

local Water = GameObject:extend()
local vector = require "lib.hump.vector"
local assets =  require "src.assets"

function Water:new(x, y, tileId)
	Water.super.new(self, x, y)
	self.name = "Water"
	self.isWater = true

	-- sprite/animation component
	self.sprite = assets.tiles
	local g = anim8.newGrid(reg.T_SIZE, reg.T_SIZE, self.sprite:getWidth(), self.sprite:getHeight())

	self.animation = anim8.newAnimation(g('1-7', 6), 0.15)

	self:setDrawLayer("waterAnims")

	return self
end

return Water
