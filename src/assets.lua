local assets = {}

love.graphics.setDefaultFilter("nearest", "nearest")

-- Images
assets.player = {}
assets.player[1] = love.graphics.newImage("assets/img/player_spritesheet.png")
assets.player[2] = love.graphics.newImage("assets/img/player_spritesheet2.png")

assets.playerDash = {}
assets.playerDash[1] = love.graphics.newImage("assets/img/player_dash.png")
assets.playerDash[2] = love.graphics.newImage("assets/img/player_dash2.png")

assets.playerPortrait = {}
assets.playerPortrait[1] = love.graphics.newImage("assets/img/player_portrait1.png")
assets.playerPortrait[2] = love.graphics.newImage("assets/img/player_portrait2.png")
assets.white = love.graphics.newImage("assets/img/white.png")
assets.grass = love.graphics.newImage("assets/img/tiles_spritesheet.png")

assets.attack = love.graphics.newImage("assets/img/burst_spritesheet.png")
assets.attackVert = love.graphics.newImage("assets/img/burst_spritesheet_vertical.png")

-- text images
assets.fight = love.graphics.newImage("assets/img/fight_text.png")
assets.ready = love.graphics.newImage("assets/img/ready_text.png")
assets.gameOver = love.graphics.newImage("assets/img/gameover_text.png")
assets.playerWin = {}
assets.playerWin[1] = love.graphics.newImage("assets/img/player1_wins.png")
assets.playerWin[2] = love.graphics.newImage("assets/img/player2_wins.png")

-- Fonts
assets.font_lg = love.graphics.newFont("assets/fonts/04b03.ttf", 64)
assets.font_md = love.graphics.newFont("assets/fonts/04b03.ttf", 48)
assets.font_sm = love.graphics.newFont("assets/fonts/04b03.ttf", 24)

-- Sfx
-- assets.music = love.audio.newSource(love.sound.newDecoder("assets/sfx/music.mp3"))
assets.sfx = {}

assets.sfx.jump = love.audio.newSource(love.sound.newDecoder("assets/sfx/woosh.wav"))
assets.sfx.death = love.audio.newSource(love.sound.newDecoder("assets/sfx/explode.wav"))
assets.sfx.ground = love.audio.newSource(love.sound.newDecoder("assets/sfx/ground.wav"))
assets.sfx.ground:setVolume(0.2)

assets.sfx.hit1 = love.audio.newSource(love.sound.newDecoder("assets/sfx/hit.wav"))
assets.sfx.hit2 = love.audio.newSource(love.sound.newDecoder("assets/sfx/hit2.wav"))

return assets
