-- 
-- MovableSystem
-- by Alphonsus
--
-- Required:
--
-- self.movable = {
-- 		velocity = { x = 0, y = 0 },
-- 		acceleration = { x = 0, y = 0 },
-- 		drag = { x = 0, y = 0 },
-- 		maxVelocity = { x = math.huge, y = math.huge },
-- 		speed = { x = 0, y = 0 } -- optional, can be used to set the acceleration for movement etc.
-- }
--

local lume = require "lib.lume"

local MovableSystem = tiny.processingSystem(class "MovableSystem")

function MovableSystem:init()
	self.filter = tiny.requireAll("movable")
end

function MovableSystem:process(e, dt)
	dt = dt * timeScale
	local mov = e.movable
	local vel, accel, maxVel, drag = mov.velocity, mov.acceleration, mov.maxVelocity, mov.drag

	-- Update velocity
	vel.x = vel.x + accel.x * dt
	vel.y = vel.y + accel.y * dt
		
	-- Update drag
	if accel.x == 0 and drag.x > 0 then
		local sign = lume.sign(vel.x)
		vel.x = vel.x - drag.x * dt * sign
		if (vel.x < 0) ~= (sign < 0) then
			vel.x = 0
		end
	end
	if accel.y == 0 and drag.y ~= 0 then
		local sign = lume.sign(vel.y)
		vel.y = vel.y - drag.y * dt
	end

	-- Update max velocity
	if maxVel.x > 0 and math.abs(vel.x) > maxVel.x then
		vel.x = maxVel.x * lume.sign(vel.x)
	end
	if maxVel.y > 0 and math.abs(vel.y) > maxVel.y then
		vel.y = maxVel.y * lume.sign(vel.y)
	end

	-- if grounded, set vel to 0
	if e.platformer and e.platformer.grounded then
		vel.y = 0
	end

	-- Update position
	e.pos.x = e.pos.x + vel.x * dt

	if e.platformer then
		if not e.platformer.grounded then
			e.pos.y = e.pos.y + vel.y * dt
		end
	else
		e.pos.y = e.pos.y + vel.y * dt
	end
end

return MovableSystem