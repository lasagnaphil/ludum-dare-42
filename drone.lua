Drone = Object:extend()

function Drone:new(x, y)
    self.image = images.drone1
    self.width = images.drone1:getWidth()
    self.height = images.drone1:getHeight()
    self.size = math.sqrt(self.width * self.width + self.height * self.height)

    self.body = love.physics.newBody(world, x, y, "dynamic")
    self.body:setGravityScale(0)
    self.body:setFixedRotation(true)
    local shape = love.physics.newRectangleShape(0, 0, self.width, self.height)
    self.fixture = love.physics.newFixture(self.body, shape, 1)
    self.fixture:setUserData(self)

    self.shootDuration = 2
    self.restDuration = 2
    self.bulletsPerSecond = 4

    local shootCount = self.shootDuration * self.bulletsPerSecond

    Timer.every(self.shootDuration + self.restDuration, function()
        Timer.every(1 / self.bulletsPerSecond, function()
            local x, y = self.body:getPosition()
            local px, py = player.body:getPosition()
            local dx, dy = px - x, py - y
            local mag = math.sqrt(dx * dx + dy * dy)
            local bulletSpeed = 100
            local bulletDamage = 10
            local vx, vy = bulletSpeed * dx / mag, bulletSpeed * dy / mag
            local bullet = Bullet(x + self.size * dx / mag, y + self.size * dy / mag, vx, vy, bulletDamage)
            bullets[#bullets + 1] = bullet
        end):limit(shootCount)
    end)
end

function Drone:update(dt)
    local x, y = self.body:getPosition()
    local vx, vy = self.body:getLinearVelocity()
    local px, py = player.body:getPosition()
    py = py - 100
    local dx, dy = px - x, py - y
    local mag = dx * dx + dy * dy
    local magThreshold = 4000
    if mag > magThreshold then
        dx = dx / mag * magThreshold
        dy = dy / mag * magThreshold
    end
    local k = 0.5
    self.body:applyForce(k * dx, k * dy)
    local rho = 0.2
    self.body:applyForce(-rho * vx, -rho * vy)
end

function Drone:draw()
    local x, y = self.body:getPosition()
    love.graphics.draw(self.image, x, y, self.body:getAngle(), 1, 1, self.width/2, self.height/2)
end

function Drone:destroy()
end
