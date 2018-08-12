Box = Object:extend()
Box:implement(Pickable)

function Box:new(x, y)
    self.image = images.box
    self.width = images.box:getWidth()
    self.height = images.box:getHeight()
    self.ground = true
    self.body = love.physics.newBody(world, x, y, "dynamic")
    local box_shape = love.physics.newRectangleShape(self.width, self.height)
    self.fixture = love.physics.newFixture(self.body, box_shape, 1)
    self.fixture:setUserData(self)

    Pickable.init(self)
end

function Box:draw()
    local x, y = self.body:getPosition()
    love.graphics.draw(self.image, x, y, self.body:getAngle(), 1, 1, self.width/2, self.height/2)
    self:drawHighlight()
end


