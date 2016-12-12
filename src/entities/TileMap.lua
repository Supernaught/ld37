GameObject = require "src.entities.GameObject"

local sti = require "lib.sti"

local TileMap = GameObject:extend()
local assets =  require "src.assets"

function TileMap:new(x, y)
	TileMap.super.new(self, x or 0, y or 0)
	self.name = "TileMap"
	self.isTileMap = true

	-- self.map = sti("maps/plain.lua")
	-- self.map = sti("maps/plain2.lua")
	self.map = sti("maps/test_24.lua")

	return self
end

function TileMap:update(dt)
end

function TileMap:draw()
	self.map:draw()
end

return TileMap