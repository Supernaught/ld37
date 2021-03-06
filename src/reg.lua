local reg = {}

-- gameplay
reg.startPlay = false
reg.gameOver = false
reg.MAX_SCORE = 100

-- game duration in sec
reg.GAME_DURATION = 90
reg.gameTime = reg.GAME_DURATION

-- reg.T_SIZE = 16
reg.T_SIZE = 24
reg.GRAVITY = -2000
reg.DEBUG_RENDERS = false
reg.DEBUG_COLLISIONS = false

-- controls
reg.controls = {}

reg.controls[1] = {
	up = 'w',
	down = 's',
	left = 'a',
	right = 'd',
	jump = 'f',
	attack = 'g',
	roll = 'h',
}

reg.controls[2] = {
	up = 'up',
	down = 'down',
	left = 'left',
	right = 'right',
	jump = 'u',
	attack = 'i',
	roll = 'o'
	-- up = 'i',
	-- down = 'k',
	-- left = 'j',
	-- right = 'l',
	-- jump = 'left',
	-- attack = 'down',
	-- roll = 'right'
}

reg.gamepad = {
	a = 'jump',
	x = 'attack'
}

return reg