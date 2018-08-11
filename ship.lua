Ship = Object:extend()

function Ship:new()
    self.image = images.ship
    self.width = images.ship:getWidth()
    self.height = images.ship:getHeight()
    self.baseline = 192
    self.ground = true
    self.body = love.physics.newBody(world, 128, self.baseline, "dynamic")
    local ship_shape = love.physics.newRectangleShape(0, 10, self.width, self.height - 20)
    self.fixture = love.physics.newFixture(self.body, ship_shape, 1)
    self.fixture:setUserData(self)
end

function Ship:update(dt)
    local x, y = ship.body:getPosition()
    self.body:applyForce(0, -gravity * self.body:getMass() * (1 + (y - ship.baseline) / ship.height))
end

function Ship:draw()
    local x,y = self.body:getPosition()
    love.graphics.draw(self.image, x, y, self.body:getAngle(), 1, 1, self.width/2, self.height/2)
end
