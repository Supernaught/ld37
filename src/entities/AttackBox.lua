local GameObject = require "src.entities.GameObject"
local ParticleSystem = require "src.entities.ParticleSystem"

local AttackBox = GameObject:extend()
local assets =  require "src.assets"

function AttackBox:new(x, y, playerOwner, direction, posFollow)
	boxLength = reg.T_SIZE * 2
	boxWidth = reg.T_SIZE * 1.2

	boxSize = {w = boxLength, h = boxWidth}

	atkDistance = reg.T_SIZE * 1.2

	if direction == 'down' then
		y = y + atkDistance
		boxSize.w = boxWidth
		boxSize.h = boxLength
	elseif direction == 'up' then
		y = y - atkDistance
		self.flippedV = true
		boxSize.w = boxWidth
		boxSize.h = boxLength
	elseif direction == 'right' then
		x = x + atkDistance
	else
		x = x - atkDistance
		self.flippedH = true
	end

	AttackBox.super.new(self, x, y)
	-- AttackBox.super.new(self, x or push:getWidth()/2, y or push:getHeight()/2)
	self.name = "AttackBox"
	self.isAttackBox = true

	self.playerOwner = playerOwner

	self.framesElapsed = 0

	-- sprite component
	self.sprite = assets.attack
	local g

	local frameSpeed = 0.03

	if direction == 'down' or direction == 'up' then
		self.sprite = assets.attackVert
		g = anim8.newGrid(reg.T_SIZE, reg.T_SIZE * 2, self.sprite:getWidth(), self.sprite:getHeight())
		self.burstAnimation = anim8.newAnimation(g(1,1,1,2,1,3,1,4), frameSpeed, 'pauseAtEnd')
	else
		self.sprite = assets.attack
		g = anim8.newGrid(reg.T_SIZE * 2, reg.T_SIZE, self.sprite:getWidth(), self.sprite:getHeight())
		self.burstAnimation = anim8.newAnimation(g('1-4',1), frameSpeed, 'pauseAtEnd')
	end

	self.animation = self.burstAnimation

	self.offset = { x = boxSize.w/2, y = boxSize.h/2 }
	-- collider
	self.collider = HC:rectangle(self.pos.x, self.pos.y, boxSize.w, boxSize.h)
	self.collider:moveTo(self.pos.x, self.pos.y)
	self.collider.parent = self

	timer.after(frameSpeed * 4, function()
		self:die()
	end)

	-- self:setDrawLayer("AttackBox")

	return self
end

function AttackBox:update(dt)
	self.framesElapsed = self.framesElapsed + 1

	if self.framesElapsed > 3 then
		-- self:die()
	end
end

function AttackBox:die()
	self.isAlive = false
	self.toRemove = true
end

function AttackBox:draw()
	-- self.collider:draw()
	-- love.graphics.setColor(150,150,100)
	-- love.graphics.rectangle("fill", self.pos.x - self.offset.x, self.pos.y - self.offset.y, boxSize.w, boxSize.h)
	-- love.graphics.setColor(255,255,255)
end

function AttackBox:onCollision(other, delta)
	-- print(other.name)
end

return AttackBox