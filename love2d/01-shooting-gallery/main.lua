function love.load()
end

function love.update(dt)
end

function love.draw()
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle("fill", 150, 200, 200, 100)
    love.graphics.setColor(1, 0.4, 0)
    love.graphics.circle("fill", 150, 150, 100)
end
