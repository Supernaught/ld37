-- 
-- TileMapSystem
-- by Alphonsus
--
-- Required:
--
-- self.map
--

local lume = require "lib.lume"

local TileMapSystem = tiny.processingSystem(class "TileMapSystem")

function TileMapSystem:init()
	self.filter = tiny.requireAll("map", "isTileMap")
end

function TileMapSystem:process(e, dt)
	e.map:update(dt)
end

return TileMapSystem