
local GameObject = require "src.entities.GameObject"
local ParticlesTrail = require "src.entities.particles.ParticlesTrail"
local ParticlesPlayerDie = require "src.entities.particles.ParticlesPlayerDie"
local ParticlesJump = require "src.entities.particles.ParticlesJump"
local AttackBox = require "src.entities.AttackBox"

local Player = GameObject:extend()
local assets =  require "src.assets"

local lume = require "lib.lume"

function Player:new(x, y, playerNumber, isUsingGamepad)
	local offset = { x = 25/2, y = 25/2 }
	Player.super.new(self, (x + offset.x) or 100, (y + offset.y) or 100, playerNumber)
	-- Player.super.new(self, x or push:getWidth()/2, y or push:getHeight()/2)
	self.name = "Player"
	self.isPlayer = true
	self.playerNumber = playerNumber
	self.isUsingGamepad = isUsingGamepad or false

	-- scoring
	self.score = 0

	-- sprite component
	self.sprite = assets.player[playerNumber]
	self.offset = offset
	self.flippedH = false
	local g = anim8.newGrid(25, 25, self.sprite:getWidth(), self.sprite:getHeight())
	self.grid = g
	self.runningAnimation = anim8.newAnimation(g('1-8',1), 0.08)
	self.idleAnimation = anim8.newAnimation(g('1-8',2), 0.1)
	self.jumpAnimation = anim8.newAnimation(g('1-4',3), 0.08)
	self.fallAnimation = anim8.newAnimation(g('5-8',3), 0.08)
	self.animation = self.fallAnimation

	self:setupParticles()
	self:setDrawLayer("player")

	self:init()

	return self
end

function Player:init()
	-- movable component
	self.movable = {
		velocity = { x = 0, y = 0 },
		acceleration = { x = 0, y = 0 },
		drag = { x = 3200, y = reg.GRAVITY },
		maxVelocity = { x = 250, y = 400 },
		speed = { x = 3500, y = 0 }, -- used to assign to acceleration
		defaultMaxVelocity = { x = 0, y = 0 },
		defaultSpeed = { x = 0, y = 0 },
		defaultDrag = { x = 0, y = 0 }
	}

	self.movable.defaultMaxVelocity = { x = self.movable.maxVelocity.x, y = self.movable.maxVelocity.y }
	self.movable.defaultSpeed = { x = self.movable.speed.x, y = self.movable.speed.y }
	self.movable.defaultDrag = { x = self.movable.drag.x, y = self.movable.drag.y }

	-- platformer
	self.platformer = {
		grounded = false,
		jumpForce = -450,
		isTouchingWall = false,
		canDoubleJump = true,
		isRolling = false,
		canRoll = true
	}

	-- collider
	self.collider = HC:rectangle(self.pos.x, self.pos.y, reg.T_SIZE - 5, reg.T_SIZE)
	self.collider['parent'] = self

	-- combat
	self.isAttackPaused = false
	-- gamepad
	self.gamepadAxis = {
		x = 0,
		y = 0,
		rt = -1,
		rtReleased = true,
		-- flags
		left = false,
		right = false,
		up = false,
		right = false,
		jump = false,
		attack = false,
		roll = false
	}
end

function Player:update(dt)
	-- log.trace(self.platformer.grounded)
	-- log.trace(self.platformer.isTouchingWall)
	-- log.trace(self.movable.pos.x)
	-- log.trace(self.movable.velocity.y .. " " .. tostring(self.platformer.grounded))
	self:moveControls()

	self:updateAnimations()

	if self.pos.y > push:getHeight() + 20 then
		if self.isAlive then
			screen:setShake(20)
			self:die(nil)
		end
	end

	if self.trailPs and self.platformer.isRolling then
		self.trailPs.ps:setPosition(self.pos.x + math.random(-2,2), self.pos.y + 5)
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

	if not self.platformer.grounded then
		if self.movable.velocity.y > 0 then
			self.animation = self.fallAnimation
		else
			self.animation = self.jumpAnimation
		end
	else
		 if math.abs(self.movable.velocity.x) > 0 then
			 self.animation = self.runningAnimation
		 else
			 self.animation = self.idleAnimation
		 end
	 end
end

function Player:setupParticles()
	local f = self.grid(1,1)
	local frame = {}
	for i, o in pairs(f) do
		frame = o
	end

	self.trailPs = ParticlesTrail(self.playerNumber)
	self.jumpPs = ParticlesJump()
	world:add(self.trailPs)
	world:add(self.jumpPs)
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
	if left and not right and self.isAlive and not reg.gameOver then
		self.movable.acceleration.x = -applySpeedX
	elseif right and not left and self.isAlive and not reg.gameOver then
		self.movable.acceleration.x = applySpeedX
	else
		self.platformer.isTouchingWall = false
		self.movable.acceleration.x = 0
	end

	-- wall jumps
	if not self.isAttackPaused then
		if self.platformer.isTouchingWall then
			if math.abs(self.movable.velocity.y) > 0.3 then
				self.movable.velocity.y = self.movable.velocity.y/1.3
			end

			-- wall slide gravity
			self.movable.drag.y = reg.GRAVITY/5
		elseif jump then
			-- holding jump key
			self.movable.drag.y = reg.GRAVITY/2
		else
			self.movable.drag.y = reg.GRAVITY
		end
	end

	if self.isUsingGamepad then
		self:gamepadControls()
	end
end

function Player:gamepadControls()
	-- gamepad stuff
	local threshold = 0.2
	self.gamepadAxis.right = false
	self.gamepadAxis.left = false
	self.gamepadAxis.down = false
	self.gamepadAxis.up = false
	self.gamepadAxis.roll = false

	if self.gamepadAxis.x > threshold then
		self.gamepadAxis.right = true
	elseif self.gamepadAxis.x < -threshold then
		self.gamepadAxis.left = true
	end

	if self.gamepadAxis.y > threshold then
		self.gamepadAxis.down = true
	elseif self.gamepadAxis.y < -threshold then
		self.gamepadAxis.up = true
	end

	if self.gamepadAxis.rt > -0.3 and self.gamepadAxis.rtReleased then
		self.gamepadAxis.rtReleased = false
		self:roll()
	elseif self.gamepadAxis.rt < -0.3 then
		self.gamepadAxis.rtReleased = true
	end
end

function Player:onCollision(other, delta)
	if other and other.name == "AttackBox" and other.isAlive and other.playerOwner.playerNumber ~= self.playerNumber then
		if self.isAlive then
			screen:setShake(20)
			playstate:playerScored(other.playerOwner.playerNumber)
			self:die(other.pos.x)
			-- other.playerOwner.score = other.playerOwner.score + 1
		end
	end
end

function Player:die(attackBoxX)
	self.isAlive = false

	lume.randomchoice({assets.sfx.hit2, assets.sfx.death}):clone():play()
	-- assets.sfx.hit2:clone():play()

	local dir = 0

	if not attackBoxX then
		dir = 0
	elseif attackBoxX > self.pos.x then
		dir = -1
	else
		dir = 1
	end

	self.movable.maxVelocity.x = self.movable.maxVelocity.x * 2 * dir
	self.movable.velocity.x = self.movable.maxVelocity.x
	self:applyJumpForce()

	self.movable.drag.x = 500

	-- self.toRemove = true
	-- respawn
	if not reg.gameOver then
		timer.after(1, function() playstate.respawnPlayer(self.playerNumber) end)
	end

	-- particles
	local psDie = ParticlesPlayerDie(self.pos.x, self.pos.y, self.playerNumber)
	world:add(psDie)
end

function Player:roll()
	if not self.isAlive then
		return
	end

	if self.platformer.canRoll and not self.platformer.isRolling and not self.isAttackPaused then
		local left = self:keyIsDown('left')
		local right = self:keyIsDown('right')
		local up = self:keyIsDown('up')
		local down = self:keyIsDown('down')

		local xSign = 0
		local ySign = 0

		if left then xSign = -1 end
		if right then xSign = 1 end
		if up then ySign = -1 end
		if down then ySign = 1 end

		if xSign == 0 and ySign == 0 then
			return
		end

		local xMultiplier = 2.5
		local yMultiplier = 1.5

		-- pseudo-normalize if diagonal
		if xSign ~= 0 and ySign ~= 0 then
			xMultiplier = xMultiplier / 1.2
			yMultiplier = yMultiplier / 1.2
		end

		self.movable.maxVelocity.x = self.movable.defaultMaxVelocity.x * xMultiplier
		self.movable.maxVelocity.y = self.movable.defaultMaxVelocity.y * yMultiplier

		self.movable.velocity.x = self.movable.maxVelocity.x * xSign
		self.movable.velocity.y = self.movable.maxVelocity.y * ySign

		self.movable.drag.x = 0
		self.movable.drag.y = 0
		self.platformer.isRolling = true
		self.platformer.canRoll = false

		timer.after(0.1, function()
			self:stopRoll()
		end)
	end
end

function Player:stopRoll()
	if self.platformer.isRolling then
		if self.platformer.grounded then
			self.platformer.canRoll = true
		end

		self.platformer.isRolling = false
		self.movable.drag.x = self.movable.defaultDrag.x
		self.movable.drag.y = self.movable.defaultDrag.y
		self.movable.maxVelocity.x = self.movable.defaultMaxVelocity.x
		self.movable.maxVelocity.y = self.movable.defaultMaxVelocity.y
	end
end

function Player:jump()
	if not self.isAlive then
		return
	end

	if not self.platformer.grounded then
		if self.platformer.canDoubleJump then
			self.platformer.canDoubleJump = false
			self:applyJumpForce(true)
			return
		end
	elseif self.platformer.grounded then
		self:applyJumpForce()
		return
	end

	local left = self:keyIsDown('left')
	local right = self:keyIsDown('right')

	if self.platformer.isTouchingWall and (left or right) then
		self:wallJump(left, right)
	end
end

function Player:attack()
	if self.isAttackPaused or not self.isAlive then
		return
	end

	atkDirection = nil
	local threshold = 0.3

	if self.isUsingGamepad then
		if math.abs(self.gamepadAxis.x) > threshold or math.abs(self.gamepadAxis.y) > threshold then
			if math.abs(self.gamepadAxis.x) > math.abs(self.gamepadAxis.y) then
				if self.gamepadAxis.x < 0 then
					atkDirection = 'left'
				else
					atkDirection = 'right'
				end
			else
				if self.gamepadAxis.y < 0 then
					atkDirection = 'up'
				else
					atkDirection = 'down'
				end
			end
		else -- if not beyond threshold
			if self.flippedH then
				atkDirection = 'left'
			else
				atkDirection = 'right'
			end
		end
	end

	if self:keyIsDown('down') then
		atkDirection = 'down'
	elseif self:keyIsDown('up') then
		atkDirection = 'up'
	elseif self.flippedH then
		atkDirection = 'left'
	else
		atkDirection = 'right'
	end

	self.isAttackPaused = true
	self:stopRoll()

	-- pause movement a bit
	self.movable.acceleration.x = 0
	self.movable.velocity.x = self.movable.velocity.x/2
	self.movable.velocity.y = self.movable.velocity.y/10
	self:slowDownSpeed(30, 0.25)

	world:addEntity(AttackBox(self.pos.x, self.pos.y, self, atkDirection, self.pos))
end

-- set speed to newSpeed for "t" seconds
function Player:slowDownSpeed(newSpeed, t)
	self.movable.speed.x = newSpeed
	self.movable.drag.y = reg.GRAVITY/3
	-- self.movable.maxVelocity.x = self.movable.maxVelocity.x * 1.5

	timer.after(t, function()
		self.movable.maxVelocity.x = self.movable.defaultMaxVelocity.x
		self.movable.speed.x = self.movable.defaultSpeed.x
		self.movable.drag.y = reg.GRAVITY/3
		self.isAttackPaused = false
	end)
end

function Player:applyJumpForce(isDoubleJump, multiplier)
	self.platformer.grounded = false
	self.movable.velocity.y = 0

	-- particles
	self.jumpPs.ps:setPosition(self.pos.x, self.pos.y + 5)
	self.jumpPs:emit()

	assets.sfx.jump:clone():play()

	if isDoubleJump then
		self.movable.velocity.y = self.platformer.jumpForce * 0.7
	else
		self.movable.velocity.y = self.platformer.jumpForce * (multiplier or 1)
	end
end

function Player:wallJump(left, right)
	local wallJumpXForce = 2000
	self.movable.velocity.x = 0

	if left then
		self.movable.velocity.x = wallJumpXForce
	elseif right then
		self.movable.velocity.x = -wallJumpXForce
	end

	self:applyJumpForce()
	self.platformer.canDoubleJump = true

	-- self.movable.speed.x = self.movable.speed.x/2

	timer.after(0.2, function()
		self.movable.speed.x = self.movable.defaultSpeed.x
	end)
end

-- key = up down left right jump attack
function Player:keyIsDown(key)
	return love.keyboard.isDown(reg.controls[self.playerNumber][key]) or self.gamepadAxis[key]
end

function Player:respawn(x, y)
	HC:remove(self.collider)
	self:init()
	self.pos.x = x
	self.pos.y = y
	self.isAlive = true
end

function Player:bounce(x, y)
	if x ~= 0 then
		self.movable.velocity.x = self.movable.velocity.x * -0.7
	end
end

return Player