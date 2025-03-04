---@diagnostic disable: lowercase-global

-- EVENTS -----------------------------------------------------------

function love.load()

    math.randomseed(os.time())

    sprites = {}
    sprites.background = love.graphics.newImage('img/background.png')
    sprites.bullet = love.graphics.newImage('img/bullet.png')
    sprites.player = love.graphics.newImage('img/player.png')
    sprites.zombie = love.graphics.newImage('img/zombie.png')
    sprites.medkit = love.graphics.newImage('img/medkit.png')

    gameState = 0
    reset()

    player = {}
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2
    player.speed = 2 * 60
    player.r = 0
    player.lives = 2

    zombies = {}

    bullets = {}

    medkits = {}

    maxSpawnTime = 5

    log = ""
end

function love.update(dt)

    if gameState == 0 then
        return
    end
    timer = timer + dt
    movePlayer(dt)

    local bulletsToRemove = {}
    local zombiesToRemove = {}
    local medkitsToRemove = {}

    for i,b in ipairs(bullets) do
        moveBullet(b, i, dt)
        if bulletOffscreen(b) then
            table.insert(bulletsToRemove, i)
        end
    end
    for zi,z in ipairs(zombies) do
        moveZombie(z, dt)
        if distanceBetweenCoordinates(z.x, z.y, player.x, player.y) < 30 then
            player.lives = player.lives - 1
            player.speed = 3 * 60
            table.insert(zombiesToRemove, zi)
        end
        if player.lives <= 0 then
            gameOver()
        end
        for bi,b in ipairs(bullets) do
            if distanceBetweenCoordinates(z.x, z.y, b.x, b.y) < 30 then
                table.insert(zombiesToRemove, zi)
                table.insert(bulletsToRemove, bi)
                score = score + 1
                break
            end
        end
    end
    for i,m in ipairs(medkits) do
        if distanceBetweenCoordinates(m.x, m.y, player.x, player.y) < 30 then
            player.lives = player.lives + 1
            lives = math.min(2, lives)
            player.speed = 2 * 60
            table.insert(medkitsToRemove, i)
        end
    end

    removeFromTable(bullets, bulletsToRemove)
    removeFromTable(zombies, zombiesToRemove)
    removeFromTable(medkits, medkitsToRemove)

    spawnTimer = spawnTimer - dt
    if spawnTimer <= 0 then
        local multiplier = 1 + math.ceil(spawnCounter / 5)
        multiplier = math.min(10, multiplier)
        for i = 1, multiplier do
            spawnZombie()
        end
        spawnTimer = scaleSpawnTimer()
        spawnMedkit()
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
        for i,m in ipairs(medkits) do
            drawMedkit(m)
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
    for i = #zombies, 1, -1 do
        table.remove(zombies,i)
    end
    for i = #medkits, 1, -1 do
        table.remove(medkits,i)
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

function removeFromTable(t, ids)

    for i,id in ipairs(ids) do
        table.remove(t, id)
    end
end

function moveBullet(b, i, dt)

    b.x = b.x + math.cos(b.r) * b.speed * dt
    b.y = b.y + math.sin(b.r) * b.speed * dt
end

function bulletOffscreen(b)

    local del = false
    if b.x > love.graphics.getWidth() or b.x < 0 then
        del = true
    end
    if b.y > love.graphics.getHeight() or b.y < 0 then
        del = true
    end
    return del
end

function scaleSpawnTimer()
    return maxSpawnTime - timer / 10
end

function reset()
    score = 0
    timer = 0
    spawnTimer = maxSpawnTime
    spawnCounter = 0
    lives = 2
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

function drawPlayer()

    if player.lives == 1 then
        love.graphics.setColor(1,0,0)
    else
        love.graphics.setColor(1,1,1)
    end
    local sprite = sprites.player
    local hh = sprite:getHeight() / 2
    local hw = sprite:getWidth() / 2
    love.graphics.draw(sprite, player.x, player.y, player.r, 1, 1, hw, hh)
end

function drawZombie(z)

    love.graphics.setColor(1,1,1)
    local sprite = sprites.zombie
    local hh = sprite:getHeight() / 2
    local hw = sprite:getWidth() / 2
    love.graphics.draw(sprite, z.x, z.y, z.r, 1, 1, hw, hh)
end

function drawBullet(b)

    love.graphics.setColor(1,1,1)
    local sprite = sprites.bullet
    local hh = sprite:getHeight() / 2
    local hw = sprite:getWidth() / 2
    love.graphics.draw(sprite, b.x, b.y, b.r, 0.5, 0.5, hw, hh)
end

function drawMedkit(m)

    love.graphics.setColor(1,1,1)
    local sprite = sprites.medkit
    local hh = sprite:getHeight() / 2
    local hw = sprite:getWidth() / 2
    love.graphics.draw(sprite, m.x, m.y, nil, 0.05, 0.05, hw, hh)
end

function spawnMedkit()
    
    local medkit = {}
    medkit.x = math.random(love.graphics.getWidth())
    medkit.y = math.random(love.graphics.getHeight())
    table.insert(medkits, medkit)
end

function spawnZombie()

    local h = love.graphics.getHeight()
    local w = love.graphics.getWidth()

    local zombie = {}
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
        zombie.y = math.random(h)
    else
        zombie.y = ry
        zombie.x = math.random(w)
    end

    zombie.r = math.atan2(player.y - zombie.y, player.x - zombie.x)

    log = "inserting new zombie in table"

    spawnCounter = spawnCounter + 1

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
