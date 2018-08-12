Turret = Object:extend()

function Turret:new(x, y)
    self.image = images.turrets[1]
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.size = math.sqrt(self.width * self.width + self.height * self.height)

    self.body = love.physics.newBody(world, x, y, "dynamic")
    local shape = love.physics.newRectangleShape(0, 0, self.width, self.height)
    self.fixture = love.physics.newFixture(self.body, shape, 1)
    self.fixture:setUserData(self)

    self.shootDuration = 3
    self.restDuration = 2
    self.bulletsPerSecond = 4

    local shootCount = self.shootDuration * self.bulletsPerSecond

    Timer.every(self.shootDuration + self.restDuration, function()
        Timer.every(1 / self.bulletsPerSecond, function()
            local x, y = self.body:getPosition()

            -- find nearby drones
            local foundDrone, dist2, dx, dy = (function()
                local dist2 = 100000000
                local drone = nil
                local dxMin, dyMin = nil, nil
                for i = 1, #drones do
                    local px, py = drones[i].body:getPosition()
                    local dx, dy = px - x, py - y
                    local d2 = dx * dx + dy * dy
                    if d2 < dist2 then
                        dist2 = d2
                        drone = drones[i]
                        dxMin, dyMin = dx, dy
                    end
                end
                return drone, dist2, dxMin, dyMin
            end)()

            if foundDrone then
                local mag = math.sqrt(dist2)
                local bulletSpeed = 100
                local bulletDamage = 10
                local vx, vy = bulletSpeed * dx / mag, bulletSpeed * dy / mag
                local bullet = Bullet(x + self.size * dx / mag, y + self.size * dy / mag, vx, vy, bulletDamage)
                bullets[#bullets + 1] = bullet
            end
        end):limit(shootCount)
    end)
end

function Turret:draw()
    local x, y = self.body:getPosition()
    love.graphics.draw(self.image, x, y, self.body:getAngle(), 1, 1, self.width/2, self.height/2)
end

function Turret:destroy()
    self.fixture:destroy()
    self.body:destroy()
    self.timer:remove()
    table.find_remove_one(turrets, self)
end
