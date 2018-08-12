Bullet = Object:extend()

function Bullet:new(x, y, vx, vy, damage)
    self.image = images.bullet1
    self.width = images.bullet1:getWidth()
    self.height = images.bullet1:getHeight()
    self.damage = damage
    self.vx = vx
    self.vy = vy

    self.body = love.physics.newBody(world, x, y, "static")
    local shape = love.physics.newRectangleShape(0, 0, self.width, self.height)
    self.body:setLinearVelocity(vx, vy)
    self.body:setMass(0)
    self.fixture = love.physics.newFixture(self.body, shape, 1)
    self.fixture:setUserData(self)
end

function Bullet:update(dt)
    local x, y = self.body:getPosition()
    self.body:setPosition(x + self.vx * dt, y + self.vy * dt)
end

function Bullet:draw()
    local x, y = self.body:getPosition()
    love.graphics.draw(self.image, x, y, self.body:getAngle(), 1, 1, self.width/2, self.height/2)
end

function Bullet:destroy()
    self.fixture:destroy()
    self.body:destroy()

    table.find_remove_one(bullets, self)
end

function Bullet:onCollisionBegin(other, coll)
    if other:is(Player) then
        other:damage(self.damage)
    end
    self:destroy()
end

function Bullet:onCollisionEnd(other, coll)
end
