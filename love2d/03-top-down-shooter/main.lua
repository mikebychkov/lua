---@diagnostic disable: lowercase-global

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
    player.speed = 2 * 60
    player.r = 0

end

function love.update(dt)
    if gameState == 0 then
        return
    end
    timer = timer + dt
    movePlayer(dt)
end

function love.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.draw(sprites.background, 0, 0)
    if gameState > 0 then
        drawPlayer()
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
end

-- FUNCTIONS --------------------------------------------------------

function movePlayer(dt)
    if love.keyboard.isDown("w") then
        player.y = player.y - player.speed * dt
    end
    if love.keyboard.isDown("s") then
        player.y = player.y + player.speed * dt
    end
    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed * dt
    end
    if love.keyboard.isDown("a") then
        player.x = player.x - player.speed * dt
    end
    player.x = math.max(0, player.x)
    player.y = math.max(0, player.y)
    player.x = math.min(love.graphics.getWidth(), player.x)
    player.y = math.min(love.graphics.getHeight(), player.y)

    player.r = math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x)
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
    love.graphics.draw(sprite, x, y, 0, 1, 1, hw, hh)
end

function drawPlayer()

    local sprite = sprites.player
    local hh = sprite:getHeight() / 2
    local hw = sprite:getWidth() / 2
    love.graphics.draw(sprite, player.x, player.y, player.r, 1, 1, hw, hh)
end

function drawSprite(sprite, x, y)

    love.graphics.draw(sprite, x, y)
end
