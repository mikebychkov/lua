
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
    resetPlayerMovement()
end

function love.update(dt)
    if gameState == 0 then
        return
    end
    timer = timer + dt
    movePlayer()
    -- resetPlayerMovement()
end

function love.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.draw(sprites.background, 0, 0)
    if gameState > 0 then
        drawSpriteWithShift(sprites.player, player.x, player.y)
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
    -- playerMovement.w = scancode == "w"
    -- playerMovement.s = scancode == "s"
    -- playerMovement.d = scancode == "d"
    -- playerMovement.a = scancode == "a"
end

-- FUNCTIONS --------------------------------------------------------

function resetPlayerMovement()
    playerMovement.w = false
    playerMovement.s = false
    playerMovement.d = false
    playerMovement.a = false
end

function movePlayer()
    if love.keyboard.isDown("w") then
        player.y = player.y - 1
    end
    if love.keyboard.isDown("s") then
        player.y = player.y + 1
    end
    if love.keyboard.isDown("d") then
        player.x = player.x + 1
    end
    if love.keyboard.isDown("a") then
        player.x = player.x - 1
    end
    player.x = math.max(0, player.x)
    player.y = math.max(0, player.y)
    player.x = math.min(love.graphics.getWidth(), player.x)
    player.y = math.min(love.graphics.getHeight(), player.y)
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

function drawSpriteWithShift(sprite, x, y)

    local hh = sprite:getHeight() / 2
    local hw = sprite:getWidth() / 2
    love.graphics.draw(sprite, x - hh, y - hw)
end

function drawSprite(sprite, x, y)

    love.graphics.draw(sprite, x, y)
end
