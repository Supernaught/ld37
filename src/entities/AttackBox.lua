local GameObject = require "src.entities.GameObject"
local ParticleSystem = require "src.entities.ParticleSystem"

local AttackBox = GameObject:extend()
local assets =  require "src.assets"

function AttackBox:new(x, y, playerOwner, direction, posFollow)
	boxSize = {x = reg.T_SIZE, y = reg.T_SIZE }
	atkDistance = reg.T_SIZE * 2

	if direction == 'down' then
		y = y + atkDistance
		boxSize.y = boxSize.y * 2
	elseif direction == 'up' then
		y = y - atkDistance
		boxSize.y = boxSize.y * 2
	elseif direction == 'right' then
		boxSize.x = boxSize.x * 2
		x = x + atkDistance
	else
		boxSize.x = boxSize.x * 2
		x = x - atkDistance
	end

	AttackBox.super.new(self, x, y)
	-- AttackBox.super.new(self, x or push:getWidth()/2, y or push:getHeight()/2)
	self.name = "AttackBox"
	self.isAttackBox = true

	self.playerOwner = playerOwner or 0

	self.framesElapsed = 0

	-- sprite component
	-- self.sprite = assets.AttackBox
	-- self.flippedH = false
	-- local g = anim8.newGrid(reg.T_SIZE, reg.T_SIZE, self.sprite:getWidth(), self.sprite:getHeight())
	-- self.idleAnimation = anim8.newAnimation(g('1-3',1), 0.1)
	-- self.animation = self.idleAnimation


	self.offset = { x = boxSize.x/2, y = boxSize.y/2 }
	-- collider
	self.collider = HC:rectangle(self.pos.x, self.pos.y, boxSize.x, boxSize.y)
	self.collider:moveTo(self.pos.x, self.pos.y)
	self.collider.parent = self

	-- self:setDrawLayer("AttackBox")

	return self
end

function AttackBox:update(dt)
	self.framesElapsed = self.framesElapsed + 1

	if self.framesElapsed > 3 then
		self:die()
	end
end

function AttackBox:die()
	self.toRemove = true
end

function AttackBox:draw()
	self.collider:draw()
	love.graphics.rectangle("fill", self.pos.x - self.offset.x, self.pos.y - self.offset.y, boxSize.x, boxSize.y)
end

function AttackBox:onCollision(other, delta)
end

return AttackBox