--
-- UpdateSystem
-- by Alphonsus
--
-- calls entity's update() function, which is usually required for most objects
--
--	Required:
--	function Object:update()
--

local UpdateSystem = tiny.processingSystem(class "UpdateSystem")

UpdateSystem.filter = tiny.requireAll("update")

function UpdateSystem:process(e, dt)
	if e.toRemove then
		world:remove(e)
		e.isAlive = false
	else
		e:update(dt)
	end
end

return UpdateSystem