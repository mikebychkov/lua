
-- EVENTS -----------------------------------------------------------

function love.load()
    sprites = {}
    sprites.background = love.graphics.newImage('img/background.png')
    sprites.bullet = love.graphics.newImage('img/bullet.png')
    sprites.player = love.graphics.newImage('img/player.png')
    sprites.zombie = love.graphics.newImage('img/zombie.png')

    gameState = 0
    reset()

    player = {}
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2

    playerMovement = {}
    playerMovement.w = false
    playerMovement.s = false
    playerMovement.d = false
    playerMovement.a = false
end

function love.update(dt)
    if gameState == 0 then
        return
    end
    timer = timer + dt
    movePlayer()
end

function love.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.draw(sprites.background, 0, 0)
    if gameState > 0 then
        love.graphics.draw(sprites.player, player.x, player.y)
    else
        drawStartPrompt()
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if gameState == 0 then
        gameState = 1
        return
    end
end

function love.keypressed(key, scancode, isrepeat)
    playerMovement.w = key == "w"
    playerMovement.s = key == "s"
    playerMovement.d = key == "d"
    playerMovement.a = key == "a"
end

-- FUNCTIONS --------------------------------------------------------

function movePlayer()
    if playerMovement.w then
        player.y = player.y - 1
    end
    if playerMovement.s then
        player.y = player.y + 1
    end
    if playerMovement.d then
        player.x = player.x + 1
    end
    if playerMovement.a then
        player.x = player.x - 1
    end
end

function reset()
    score = 0
    timer = 0
end

function drawStartPrompt()
    love.graphics.setColor(1,0,0)
    love.graphics.setFont(love.graphics.newFont(50))
    love.graphics.printf("CLICK TO START", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
end

