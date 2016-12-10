local GameObject = require "src.entities.GameObject"
local ParticleSystem = require "src.entities.ParticleSystem"

local AttackBox = GameObject:extend()
local assets =  require "src.assets"

function AttackBox:new(x, y, playerOwner, direction, posFollow)
	boxLength = reg.T_SIZE * 3
	boxWidth = reg.T_SIZE * 1.2

	boxSize = {w = boxLength, h = boxWidth}

	atkDistance = reg.T_SIZE * 1.5

	if direction == 'down' then
		y = y + atkDistance
		boxSize.w = boxWidth
		boxSize.h = boxLength
	elseif direction == 'up' then
		y = y - atkDistance
		boxSize.w = boxWidth
		boxSize.h = boxLength
	elseif direction == 'right' then
		x = x + atkDistance
	else
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


	self.offset = { x = boxSize.w/2, y = boxSize.h/2 }
	-- collider
	self.collider = HC:rectangle(self.pos.x, self.pos.y, boxSize.w, boxSize.h)
	self.collider:moveTo(self.pos.x, self.pos.y)
	self.collider.parent = self

	-- self:setDrawLayer("AttackBox")

	return self
end

function AttackBox:update(dt)
	self.framesElapsed = self.framesElapsed + 1

	if self.framesElapsed > 2 then
		self:die()
	end
end

function AttackBox:die()
	self.isAlive = false
	self.toRemove = true
end

function AttackBox:draw()
	self.collider:draw()
	love.graphics.rectangle("fill", self.pos.x - self.offset.x, self.pos.y - self.offset.y, boxSize.w, boxSize.h)
end

function AttackBox:onCollision(other, delta)
end

return AttackBox