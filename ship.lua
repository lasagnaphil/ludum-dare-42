Ship = Object:extend()

function Ship:new()
    self.image = images.ship
    self.width = images.ship:getWidth()
    self.height = images.ship:getHeight()
    self.baseline = 210

    self.ground = true

    self.body = love.physics.newBody(world, 128, self.baseline, "dynamic")
    local shape = love.physics.newRectangleShape(0, 10, self.width, self.height - 20)
    self.fixture = love.physics.newFixture(self.body, shape, 1)
    self.fixture:setDensity(0.9)
    self.fixture:setUserData(self)
end

function Ship:update(dt)
    local x, y = ship.body:getPosition()
    local shape = ship.fixture:getShape()
    local vertices = {ship.body:getWorldPoints(shape:getPoints())}
    self.sunkVertices = computeSunkVertices(vertices, self.baseline)
    if self.sunkVertices then
        local cx, cy, sunkArea = computeCentroid(self.sunkVertices)
        local force = 3 * Constants.gravity * (sunkArea / 32 / 32) * Constants.waterDensity
        self.body:applyForce(0, -force, cx, cy)
        self.cx, self.cy = cx, cy
    else
        self.cx, self.cy = nil, nil
    end

end

function Ship:draw()
    local x,y = self.body:getPosition()
    love.graphics.draw(self.image, x, y, self.body:getAngle(), 1, 1, self.width/2, self.height/2)

    if debug and self.sunkVertices and self.cx and self.cy then
        if #self.sunkVertices >= 6 then
            love.graphics.setColor(1, 1, 0)
            love.graphics.polygon("line", unpack(self.sunkVertices))
        end
        love.graphics.setColor(0, 0, 1)
        love.graphics.line(0, self.baseline, 256, self.baseline)
        love.graphics.setColor(1, 0, 0)
        love.graphics.circle("fill", self.cx, self.cy, 3, 8)
        love.graphics.setColor(1, 1, 1)
    end
end
