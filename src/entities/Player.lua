local GameObject = require "src.entities.GameObject"
local ParticleSystem = require "src.entities.ParticleSystem"
local AttackBox = require "src.entities.AttackBox"

local Player = GameObject:extend()
local assets =  require "src.assets"

function Player:new(x, y, playerNumber)
	Player.super.new(self, x or 100, y or 100, playerNumber)
	-- Player.super.new(self, x or push:getWidth()/2, y or push:getHeight()/2)
	self.name = "Player"
	self.isPlayer = true
	self.playerNumber = playerNumber

	-- sprite component
	self.sprite = assets.player
	self.flippedH = false
	self.offset = { x = 25/2, y = 25/2 }
	local g = anim8.newGrid(25, 25, self.sprite:getWidth(), self.sprite:getHeight())
	self.idleAnimation = anim8.newAnimation(g('1-8',1), 0.07)
	self.animation = self.idleAnimation

	-- movable component
	self.movable = {
		velocity = { x = 0, y = 0 },
		acceleration = { x = 0, y = 0 },
		drag = { x = 3200, y = reg.GRAVITY },
		maxVelocity = { x = 250, y = 400 },
		speed = { x = 4500, y = 0 } -- used to assign to acceleration
	}

	-- platformer
	self.platformer = {
		grounded = false,
		jumpForce = -450,
		isTouchingWall = false
	}

	-- collider
	self.collider = HC:rectangle(self.pos.x, self.pos.y, reg.T_SIZE - 5, reg.T_SIZE)
	self.collider['parent'] = self

	-- self:setupParticles()
	self:setDrawLayer("player")

	-- gamepad
	self.gamepadAxis = {
		x = 0,
		y = 0,
		left = false,
		right = false,
		up = false,
		right = false,
		jump = false,
		attack = false
	}

	return self
end

function Player:update(dt)
	-- log.trace(self.platformer.grounded)
	-- log.trace(self.platformer.isTouchingWall)
	-- log.trace(self.movable.pos.x)
	-- log.trace(self.movable.velocity.y .. " " .. tostring(self.platformer.grounded))
	self:moveControls()

	self:updateAnimations()

	if self.trailPs then
		self.trailPs.ps:setPosition(self.pos.x + math.random(-2,2), self.pos.y + 10)
		self.trailPs.ps:emit(1)
	end
end

function Player:draw()
end

function Player:updateAnimations()
	if self.movable.acceleration.x > 0 then
		self.flippedH = false
	elseif self.movable.acceleration.x < 0 then
		self.flippedH = true
	end
end

function Player:setupParticles()
	self.trailPs = ParticleSystem()
	self.trailPs:setDrawLayer("playerParticles")
	self.trailPs.ps:setPosition(push:getWidth()/2, push:getHeight()/2)
	self.trailPs.ps:setParticleLifetime(0.2, 2)
	self.trailPs.ps:setDirection(1.5*3.14)
	self.trailPs.ps:setSpread(3.14/3)
	self.trailPs.ps:setLinearAcceleration(0, 400)
	self.trailPs.ps:setLinearDamping(50)
	self.trailPs.ps:setSpin(0, 30)
	self.trailPs.ps:setColors(82, 127, 57, 255)
	self.trailPs.ps:setRotation(0, 2*3.14)
	self.trailPs.ps:setInsertMode('random')
	self.trailPs.ps:setSizes(0.4, 0)
	world:add(self.trailPs)
end

function Player:moveControls()
	local left = self:keyIsDown('left')
	local right = self:keyIsDown('right')
	local jump = self:keyIsDown('jump')

	local applySpeedX = self.movable.speed.x

	-- if not self.platformer.grounded then
	-- 	applySpeedX = applySpeedX / 3
	-- end

	-- walk movement
	if left and not right then
		self.movable.acceleration.x = -applySpeedX
	elseif right and not left then
		self.movable.acceleration.x = applySpeedX
	else
		self.platformer.isTouchingWall = false
		self.movable.acceleration.x = 0
	end

	-- wall jumps
	if self.platformer.isTouchingWall then
		if self.movable.velocity.y < 0 then
			self.movable.velocity.y = self.movable.velocity.y/1.1
		end
		self.movable.drag.y = reg.GRAVITY/5
	elseif jump then
		self.movable.drag.y = reg.GRAVITY/2
	else
		self.movable.drag.y = reg.GRAVITY
	end

	-- gamepad walk
	local threshold = 0.2
	-- log.trace(self.gamepadAxis.x .. " " .. self.gamepadAxis.y)
	self.gamepadAxis.right = false
	self.gamepadAxis.left = false
	self.gamepadAxis.down = false
	self.gamepadAxis.up = false

	if self.gamepadAxis.x > threshold then
		self.gamepadAxis.right = true
	elseif self.gamepadAxis.x < -threshold then
		self.gamepadAxis.left = true
	elseif self.gamepadAxis.y > threshold then
		self.gamepadAxis.down = true
	elseif self.gamepadAxis.y < -threshold then
		self.gamepadAxis.up = true
	end
end

function Player:onCollision(other, delta)
	if other and other.name == "AttackBox" and other.playerOwner ~= self.playerNumber then
		self:die()
	end
end

function Player:die()
	if self.isAlive then
		print('die')
		self.isAlive = false
		screen:setShake(10)
		self.toRemove = true
	end
end

function Player:jump()
	if not self.platformer.grounded then
		log.trace("cant jump")
	elseif self.platformer.grounded then
		self:applyJumpForce()
	end

	local left = love.keyboard.isDown(reg.controls[self.playerNumber].left)
	local right = love.keyboard.isDown(reg.controls[self.playerNumber].right)

	if self.platformer.isTouchingWall and (left or right) then
		self:wallJump()
	end
end

function Player:attack()
	atkDirection = nil

	if self:keyIsDown('down') then
		atkDirection = 'down'
	elseif self:keyIsDown('up') then
		atkDirection = 'up'
	elseif self.flippedH then
		atkDirection = 'left'
	else
		atkDirection = 'right'
	end

	world:addEntity(AttackBox(self.pos.x, self.pos.y, self.playerNumber, atkDirection, self.pos))
end

function Player:applyJumpForce()
	self.platformer.grounded = false
	self.movable.velocity.y = self.platformer.jumpForce
end

function Player:wallJump()
	local left = self:keyIsDown('left')
	local right = self:keyIsDown('right')

	local wallJumpXForce = 20000

	self.movable.velocity.x = 0

	if left then
		self.movable.velocity.x = wallJumpXForce
	else
		self.movable.velocity.x = -wallJumpXForce
	end

	self:applyJumpForce()
	log.trace("walljump")
end

-- key = up down left right jump attack
function Player:keyIsDown(key)
	return love.keyboard.isDown(reg.controls[self.playerNumber][key]) or self.gamepadAxis[key]
end

return Player
