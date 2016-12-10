function love.conf(t)
	t.title = "Game Title"
	local pixelScale = 2

	-- 16x16 tile size
	-- local tileSize = 16 local tileWidth = 30 local tileHeight = 20
	
	-- 24x24 tile size
	local tileSize = 24 local tileWidth = 24 local tileHeight = 15


	t.window.width = tileSize * tileWidth * pixelScale
	t.window.height = tileSize * tileHeight * pixelScale

	print(t.window.width)
	print(t.window.height)

	-- t.window.fullscreen = true
	-- t.window.fullscreentype = "exclusive"
end
