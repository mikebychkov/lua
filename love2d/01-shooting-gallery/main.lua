function love.load()
    target = {}
    target.radius = 50

    placeTheTarget()

    score = 0
    timer = 10

    gameFont = love.graphics.newFont(30)
end

function love.update(dt)
    if timer > 0 then
        timer = timer - dt
    else
        target.x = -1000
        target.y = -1000
    end
end

function love.draw()

    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", target.x, target.y, target.radius)

    love.graphics.setColor(0, 1, 0)
    love.graphics.setFont(gameFont)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("Time: " .. timer, 500, 10)

    if timer <= 0 then
        love.graphics.print("Your score: " .. score, 250, 200)
    end
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

function love.mousepressed(x, y, button, istouch, presses)
    if button ~= 1 then -- not primary button
        return
    end
    if isInTarget2(x, y) then
        score = score + 1
        placeTheTarget()
    end
end

function placeTheTarget()
    target.x = math.random(target.radius, love.graphics.getWidth() - target.radius)
    target.y = math.random(target.radius, love.graphics.getHeight() - target.radius)
end
