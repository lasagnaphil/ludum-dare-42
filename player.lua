Player = Object:extend()

function Player:new()
    self.image = images.player
    self.width = images.player:getWidth()
    self.height = images.player:getHeight()

    self.health = 100

    self.facingLeft = false
    self.onGround = false
    self.pickedObject = nil

    self.body = love.physics.newBody(world, 128, 128, "dynamic")
    self.body:setFixedRotation(true)
    local shape = love.physics.newRectangleShape(0, 0, self.width, self.height)
    self.fixture = love.physics.newFixture(self.body, shape, 1)
    self.fixture:setUserData(self)
    self.body:setMass(1)
    self.pickupJoint = nil
end

function Player:keypressed(key, scancode, isrepeat)
    local x, y = self.body:getPosition() 
    local jumpForce = 150
    if key == "up" or key == "space" then
        local shouldJump = false
        world:rayCast(x, y, x, y + self.height/2 + 2, function(fixture, x, y, xn, yn, fraction)
            local obj = fixture:getUserData()
            if obj.ground then
                shouldJump = true
                return 0
            end
            return -1
        end)
        if shouldJump then
            self.body:applyLinearImpulse(0, -jumpForce)
        end
    end
    if key == "c" then
        if self.pickedObject then
            self:dropObject()
        else
            local xp = self.facingLeft and (x - self.width/2 - 3) or (x + self.width/2 + 3)
            local pickedUpObject = nil
            local dist2 = 1000000
            world:rayCast(x, y, xp, y, function(fixture, x, y, xn, yn, fraction)
                local obj = fixture:getUserData()
                if obj.pickable then
                    pickedUpObject = obj
                    return 0
                end
                return -1
            end)

            if pickedUpObject then
                self:pickupObject(pickedUpObject)
            end
        end
    end
end

function Player:update(dt)
    local vx, vy = self.body:getLinearVelocity()
    local threshold = 50
    local moveForce = 200
    if love.keyboard.isDown("left") and vx > -threshold then
        self:setFacingLeft(true)
        self.body:applyForce(-moveForce, 0)
    end
    if love.keyboard.isDown("right") and vx < threshold then
        self:setFacingLeft(false)
        self.body:applyForce(moveForce, 0)
    end
end

function Player:draw()
    local x, y = self.body:getPosition()
    if self.facingLeft then
        love.graphics.draw(self.image, x, y, self.body:getAngle(), -1, 1, self.width/2, self.height/2)
    else
        love.graphics.draw(self.image, x, y, self.body:getAngle(), 1, 1, self.width/2, self.height/2)
    end
end

function Player:setFacingLeft(facingLeft)
    if self.facingLeft ~= facingLeft then
        self.facingLeft = facingLeft
        if self.pickedObject then
            local x, y = self.body:getPosition()
            if self.facingLeft then
                self.pickedObject.body:setPosition(x - self.width/2 - self.pickedObject.width/2, y)
            else
                self.pickedObject.body:setPosition(x + self.width/2 + self.pickedObject.width/2, y)
            end
        end
    end
end

function Player:pickupObject(other)
    -- Attach the other object to the player's pickup joint
    local x, y = self.body:getPosition()
    if self.facingLeft then
        other.body:setPosition(x - self.width/2 - other.width/2, y)
    else 
        other.body:setPosition(x + self.width/2 + other.width/2, y)
    end
    other.isPicked = true
    other.body:setAngularVelocity(0)
    other.body:setAngle(0)
    other.body:setFixedRotation(true)
    local ox, oy = other.body:getPosition()
    self.pickupJoint = love.physics.newDistanceJoint(self.body, other.body, x, y, ox, oy, true)
    self.pickedObject = other
end

function Player:dropObject()
    self.pickupJoint:destroy()
    self.pickupJoint = nil

    self.pickedObject.isPicked = false
    self.pickedObject.isReachable = false
    self.pickedObject.body:setFixedRotation(false)
    self.pickedObject = nil
end

function Player:damage(damage)
    self.health = self.health - damage
end
