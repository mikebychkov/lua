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

    log = ""
end

function love.update(dt)

    if gameState == 0 then
        return
    end
    timer = timer + dt
    movePlayer(dt)
    for i,b in ipairs(bullets) do
        moveBullet(b, i, dt)
    end
    for zi,z in ipairs(zombies) do
        moveZombie(z, dt)
        if distanceBetweenCoordinates(z.x, z.y, player.x, player.y) < 30 then
            gameOver()
        end
        for bi,b in ipairs(bullets) do
            if distanceBetweenCoordinates(z.x, z.y, b.x, b.y) < 30 then
                table.remove(zombies,zi)
                table.remove(bullets,bi)
                score = score + 1
                break
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
        reset()
        return
    end

    log = "Zombies: " .. #zombies

    shootTheBullet()
end

function love.keypressed(key, scancode, isrepeat)

    log = "key pressed " .. key .. " " .. love.timer.getTime()

    if key == "space" then
        spawnZombie()
        log = log .. " " .. #zombies
    end
end

-- FUNCTIONS --------------------------------------------------------

function gameOver()
    gameState = 0
    for i,z in ipairs(zombies) do
        table.remove(zombies,i)
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

function moveBullet(b, i, dt)

    b.x = b.x + math.cos(b.r) * b.speed * dt
    b.y = b.y + math.sin(b.r) * b.speed * dt

    local del = false
    if b.x > love.graphics.getWidth() or b.x < 0 then
        del = true
    end
    if b.y > love.graphics.getHeight() or b.y < 0 then
        del = true
    end
    if del then
        table.remove(bullets, i)
    end
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
    -- love.graphics.print(log, 10, 30)
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
    love.graphics.draw(sprite, b.x, b.y, b.r, 0.5, 0.5, hw, hh)
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
    zombie.r = math.atan2(player.y - zombie.y, player.x - zombie.x)
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

    log = "inserting new zombie in table"

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
