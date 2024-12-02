function love.load()
    target = {}
    target.x = 300
    target.y = 300
    target.radius = 50
end

function love.update(dt)
end

function love.draw()
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", target.x, target.y, target.radius)
end
