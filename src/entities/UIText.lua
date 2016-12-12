local UIText = Object:extend()

function UIText:drawHud()
	if self.visible == false then
        return
    end
    
	if self.font then
		love.graphics.setFont(self.font)
	else
		love.graphics.setFont(love.graphics.newFont(self.fontSize))
	end

	if self.color then
		love.graphics.setColor(self.color.red, self.color.green, self.color.blue, (self.color.alpha or 255))
	end

	love.graphics.printf(self.text, self.pos.x, self.pos.y, self.width, self.align)

	love.graphics.setColor(255,255,255,255)
	love.graphics.setFont(love.graphics.newFont())
end

function UIText:new(text, x, y, width, align, fontSize, font, color)
	-- Draw UI System
	self.pos = {x = x or 0, y = y or 0}
	self.text = text or ""
	self.width = width or love.graphics.getWidth()
	self.align = align or "center"
	self.fontSize = fontSize or 20
	self.color = color or nil
	self.font = font or nil
	self.hudForeground = true
	self.inCamera = false

	self.visible = true

	return self
end

return UIText