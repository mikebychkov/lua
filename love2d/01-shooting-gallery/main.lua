function love.load()
    target = {}
    target.x = 300
    target.y = 300
    target.radius = 50

    score = 0
    timer = 0

    gameFont = love.graphics.newFont(30)
end

function love.update(dt)
end

function love.draw()
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", target.x, target.y, target.radius)

    love.graphics.setColor(0, 1, 0)
    love.graphics.setFont(gameFont)
    love.graphics.print("Score: " .. score, 10, 10)
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
    end
end

