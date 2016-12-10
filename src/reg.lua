local reg = {}

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
	attack = 'g'
}

reg.controls[2] = {
	up = 'up',
	down = 'down',
	left = 'left',
	right = 'right',
	jump = 'o',
	attack = 'p',
}

return reg