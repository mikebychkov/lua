-- EVENTS

function love.load()

    reset()
    gameState = 0

    target = {}
    target.radius = 50

    placeTheTarget()

    gameFont = love.graphics.newFont(30)

    sprites = {}

    sprites.sky = love.graphics.newImage('img/sky.png')
    sprites.target = love.graphics.newImage('img/target.png')
    sprites.crosshairs = love.graphics.newImage('img/crosshairs.png')

    love.mouse.setVisible(false)
end

function love.update(dt)

    if gameState == 0 then
        return
    end
    if timer > 0 then
        timer = timer - dt
    end
    if timer < 0 then
        timer = 0
        gameState = 0
    end
end

function love.draw()

    love.graphics.setColor(1, 1, 1)
    drawSprite(sprites.sky, 0, 0)
    if gameState > 0 then
        drawSpriteWithShift(sprites.target, target.x, target.y)
    else
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf("CLICK TO START", 0, 250, love.graphics.getWidth(), "center")
    end
    love.graphics.setColor(0, 1, 0)
    drawSpriteWithShift(sprites.crosshairs, love.mouse.getX(), love.mouse.getY())

    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(gameFont)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.printf("Time: " .. math.ceil(timer), 0, 10, love.graphics.getWidth() - 10, "right")
end

function love.mousepressed(x, y, button, istouch, presses)

    if button ~= 1 then -- not primary button
        return
    end
    if gameState == 0 then
        reset()
        gameState = 1
        return
    end
    if isInTarget2(x, y) then
        score = score + 1
        placeTheTarget()
    end
end

-- FUNCTIONS

function reset()

    score = 0
    timer = 10
end

function drawSpriteWithShift(sprite, x, y)

    local hh = sprite:getHeight() / 2
    local hw = sprite:getWidth() / 2
    love.graphics.draw(sprite, x - hh, y - hw)
end

function drawSprite(sprite, x, y)

    love.graphics.draw(sprite, x, y)
end

function isInTarget(x, y)

    local rsl1 = false
    if x < (target.x + target.radius) and y < (target.y + target.radius) then
        rsl1 = true
    end
    local rsl2 = false
    if x > (target.x - target.radius) and y > (target.y - target.radius) then
        rsl2 = true
    end

    return rsl1 and rsl2
end

function isInTarget2(x, y)

    local distance = math.sqrt((x - target.x)^2 + (y - target.y)^2)

    return distance < target.radius
end

function placeTheTarget()

    target.x = math.random(target.radius, love.graphics.getWidth() - target.radius)
    target.y = math.random(target.radius, love.graphics.getHeight() - target.radius)
end
