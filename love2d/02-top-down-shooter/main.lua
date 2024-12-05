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

    zombies = {}

    bullets = {}
end

function love.update(dt)

    if gameState == 0 then
        return
    end
    timer = timer + dt
    movePlayer(dt)
    for i,b in ipairs(bullets) do
        moveBullet(b, dt)
    end
    for zi,z in ipairs(zombies) do
        moveZombie(z, dt)
        if distanceBetweenCoordinates(z.x, z.y, player.x, player.y) < 30 then
            gameOver()
        end
        for bi,b in ipairs(bullets) do
            if distanceBetweenCoordinates(z.x, z.y, b.x, b.y) < 30 then
                zombies[zi] = nil
                bullets[bi] = nil
                score = score + 1
            end
        end
    end
end

function love.draw()

    drawBackground()
    if gameState > 0 then
        drawPlayer()
    else
        drawStartPrompt()
    end
    if gameState > 0 then
        for i,z in ipairs(zombies) do
            drawZombie(z)
        end
        for i,b in ipairs(bullets) do
            drawBullet(b)
        end
    end
    drawStats()
end

function love.mousepressed(x, y, button, istouch, presses)

    if gameState == 0 then
        gameState = 1
        return
    end

    shootTheBullet()
end

function love.keypressed(key, scancode, isrepeat)

    if key == "space" then
        spawnZombie()
    end
end

-- FUNCTIONS --------------------------------------------------------

function gameOver()
    gameState = 0
    for i,z in ipairs(zombies) do
        zombies[i] = nil
    end
end

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

function moveZombie(z, dt)

    z.r = math.atan2(player.y - z.y, player.x - z.x)
    z.x = z.x + math.cos(z.r) * z.speed * dt
    z.y = z.y + math.sin(z.r) * z.speed * dt
end

function moveBullet(b, dt)

    b.x = b.x + math.cos(b.r) * b.speed * dt
    b.y = b.y + math.sin(b.r) * b.speed * dt
end

function reset()
    score = 0
    timer = 0
end

function drawBackground()

    love.graphics.setColor(1,1,1)
    love.graphics.draw(sprites.background, 0, 0)
end

function drawStats()

    love.graphics.setColor(0,0,0)
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.printf("Time: " .. math.ceil(timer), 0, 10, love.graphics.getWidth() - 10, "right")
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

function drawZombie(z)

    local sprite = sprites.zombie
    local hh = sprite:getHeight() / 2
    local hw = sprite:getWidth() / 2
    love.graphics.draw(sprite, z.x, z.y, z.r, 1, 1, hw, hh)
end

function drawBullet(b)

    local sprite = sprites.bullet
    local hh = sprite:getHeight() / 2
    local hw = sprite:getWidth() / 2
    love.graphics.draw(sprite, b.x, b.y, b.r, 1, 1, hw, hh)
end

function drawSprite(sprite, x, y)

    love.graphics.draw(sprite, x, y)
end

function spawnZombie()

    local h = love.graphics.getHeight()
    local w = love.graphics.getWidth()

    local zombie = {}
    zombie.x = math.random(w)
    zombie.y = math.random(h)
    zombie.r = math.atan2(player.x - zombie.y, player.y - zombie.x)
    zombie.speed = 100

    local r1 = math.random(2)
    local r2 = math.random(2)

    local rx = 0
    local ry = 0

    if r1 == 2 then
        rx = w
        ry = h
    end

    if r2 == 1 then
        zombie.x = rx
    else
        zombie.y = ry
    end

    table.insert(zombies, zombie)
end

function shootTheBullet()

    bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.r = math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x)
    bullet.speed = 500

    table.insert(bullets, bullet)
end

function distanceBetweenCoordinates(x1, y1, x2, y2)

    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end
