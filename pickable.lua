Pickable = Object:extend()

function Pickable:init()
    self.pickable = true
    self.isReachable = false
    self.isPicked = false
end

function Pickable:drawHighlight()
    if self.isReachable then
        love.graphics.setColor(1, 1, 0)
        drawHighlight(self.fixture, self.body)
        love.graphics.setColor(1, 1, 1)
    end
    if self.isPicked then
        love.graphics.setColor(0, 1, 0)
        drawHighlight(self.fixture, self.body)
        love.graphics.setColor(1, 1, 1)
    end
end


