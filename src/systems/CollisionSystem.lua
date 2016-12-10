-- 
-- CollisionSystem
-- by Alphonsus
--
-- checks for collisions
-- will call the onCollision() functions of the two colliding objects
--
-- Required:
--   self.collider = HC.rectangle(self.pos.x, self.pos.y, self.sprite:getWidth(), self.sprite:getHeight())
--   self.collider['parent'] = self
--
--   function Object:onCollision(other, delta) end
--

local CollisionSystem = tiny.processingSystem(class "CollisionSystem")

CollisionSystem.filter = tiny.requireAll("collider", "pos", "onCollision")

function CollisionSystem:init()
end

function CollisionSystem:process(e, dt)
	local pos = e.pos
	local col = e.collider

	if reg.DEBUG_COLLISIONS then
		e.collider:draw()
	end

	-- update rotation
	col:setRotation(e.angle)

	-- update position
	col:moveTo(pos.x, pos.y)

	-- default not grounded so object will fall
	if e.platformer then
		hasCollidedSolidBottom = false
		-- col.parent.platformer.grounded = false
		e.platformer.isTouchingWall = false
	end

	adjustedY = false

	-- check collisions
	for col2, delta in pairs(HC:collisions(col)) do
		if col.parent.platformer then
			-- resolve collision for platformer
			if col2.isSolid then
				if not hasCollidedSolidBottom then
					hasCollidedSolidBottom = true
				end

				col.parent.pos.x = col.parent.pos.x + delta.x

				if not adjustedY and not col.parent.platformer.grounded then
					col.parent.pos.y = col.parent.pos.y + delta.y
					-- col.parent.movable.velocity.y = col.parent.movable.velocity.y + delta.y
					-- adjustedY = true
				end

				-- move collision box
				col:moveTo(col.parent.pos.x, col.parent.pos.y)

				-- check if grounded
				if delta.y < 0 and e.movable.velocity.y >= 0 then
					col.parent.platformer.grounded = true
				end

				-- for walljumping
				if not col.parent.platformer.grounded and math.abs(delta.x) > 0 then
					e.platformer.isTouchingWall = true
				end

				if delta.y > 0 and e.movable.velocity.y < 0 then
					e.movable.velocity.y = 0
				end
			end
		end

		col.parent:onCollision(col2.parent, delta)

		if col2.parent then
			col2.parent:onCollision(col.parent, delta)
		end
	end

	if e.platformer and not hasCollidedSolidBottom then
		col.parent.platformer.grounded = false
	end

	if col.toRemove then
		HC:remove(col)
	end

	-- if col2.toRemove then
		-- HC:remove(col2)
	-- end
end

function CollisionSystem:onAdd(e)
	-- print(e.name .. " added to col")
end

function CollisionSystem:onRemove(e)
end

return CollisionSystem