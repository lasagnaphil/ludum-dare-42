Title = Object:extend()

function Title:new()
end

function Title:draw()
    love.graphics.draw(images.background)
    love.graphics.draw(images.ocean)
    love.graphics.push()
    love.graphics.scale(2, 2)
    love.graphics.printf("raft defense", 0, 40, 128, "center")
    love.graphics.printf("press enter to start", 0, 75, 128, "center")
    love.graphics.pop()
end

function Title:update(dt)
end

function Title:keypressed(key, scancode, isrepeat)
    if key == "return" then
        nextState = Game()
    end
end
