local GameObject = require "src.entities.GameObject"
local ParticleSystem = require "src.entities.ParticleSystem"

local Player = GameObject:extend()
local assets =  require "src.assets"

function Player:new(x, y)
	Player.super.new(self, 100,100)
	-- Player.super.new(self, x or push:getWidth()/2, y or push:getHeight()/2)
	self.name = "Player"
	self.isPlayer = true

	-- sprite component
	self.sprite = assets.player
	self.flippedH = false
	self.offset = { x = reg.T_SIZE/2, y = reg.T_SIZE/2 }
	local g = anim8.newGrid(reg.T_SIZE, reg.T_SIZE, self.sprite:getWidth(), self.sprite:getHeight())
	self.idleAnimation = anim8.newAnimation(g('1-3',1), 0.1)
	self.animation = self.idleAnimation

	-- movable component
	self.movable = {
		velocity = { x = 0, y = 0 },
		acceleration = { x = 0, y = 0 },
		drag = { x = 2500, y = reg.GRAVITY },
		maxVelocity = { x = 200, y = 320 },
		speed = { x = 3000, y = 0 } -- used to assign to acceleration
	}

	self.platformer = {
		grounded = false,
		jumpForce = -300,
		isTouchingWall = false
	}

	-- collider
	self.collider = HC:rectangle(self.pos.x, self.pos.y, reg.T_SIZE, reg.T_SIZE)
	self.collider['parent'] = self

	-- self:setupParticles()
	self:setDrawLayer("player")

	return self
end

function Player:update(dt)
	-- log.trace(self.platformer.grounded)
	-- log.trace(self.platformer.isTouchingWall)
	-- log.trace(self.movable.pos.x)
	-- log.trace(self.movable.velocity.y .. " " .. tostring(self.platformer.grounded))
	self:moveControls()

	if self.trailPs then
		self.trailPs.ps:setPosition(self.pos.x + math.random(-2,2), self.pos.y + 10)
		self.trailPs.ps:emit(1)
	end
end

function Player:draw()
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
	local left = love.keyboard.isDown('left')
	local right = love.keyboard.isDown('right')
	local jump = love.keyboard.isDown('z')

	local applySpeedX = self.movable.speed.x

	-- if not self.platformer.grounded then
	-- 	applySpeedX = applySpeedX / 3
	-- end

	if left and not right then
		self.movable.acceleration.x = -applySpeedX
	elseif right and not left then
		self.movable.acceleration.x = applySpeedX
	else
		self.platformer.isTouchingWall = false
		self.movable.acceleration.x = 0
	end

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
end

function Player:onCollision(other, delta)
end

function Player:jump()
	if not self.platformer.grounded then
		log.trace("cant jump")
	elseif self.platformer.grounded then
		self:applyJumpForce()
	end


	local left = love.keyboard.isDown('left')
	local right = love.keyboard.isDown('right')

	if self.platformer.isTouchingWall and (left or right) then
		self:wallJump()
	end
end

function Player:applyJumpForce()
	self.platformer.grounded = false
	self.movable.velocity.y = self.platformer.jumpForce
end

function Player:wallJump()
	local left = love.keyboard.isDown('left')
	local right = love.keyboard.isDown('right')

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

return Player