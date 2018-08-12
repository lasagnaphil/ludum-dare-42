Player = Object:extend()

function Player:new()
    self.image = images.player
    self.width = images.player:getWidth()
    self.height = images.player:getHeight()

    self.facingLeft = false
    self.onGround = false
    self.objectsSteppingOn = {}
    self.pickedObject = nil
    self.objectsToPickup = {}

    self.body = love.physics.newBody(world, 128, 128, "dynamic")
    self.body:setFixedRotation(true)
    local shape = love.physics.newRectangleShape(0, 0, self.width, self.height)
    self.fixture = love.physics.newFixture(self.body, shape, 1)
    self.fixture:setUserData(self)
    self.pickupJoint = nil
end

function Player:keypressed(key, scancode, isrepeat)
    local x, y = self.body:getPosition()
    if key == "up" or key == "space" then
        if #self.objectsSteppingOn > 0 then
            self.body:applyLinearImpulse(0, -50)
        end
    end
    if key == "c" then
        if self.pickedObject == nil then
            if #self.objectsToPickup > 0 then
                local minDist2 = 10000000000
                local closestIndex = nil
                for i, object in ipairs(self.objectsToPickup) do
                    local ox, oy = object.body:getPosition()
                    local dist2 = (x - ox) * (x - ox) + (y - oy) * (y - oy)
                    if dist2 < minDist2 then
                        minDist2 = dist2
                        closestIndex = i
                    end
                end
                self:pickupObject(self.objectsToPickup[closestIndex])
                table.remove(self.objectsToPickup, closestIndex)
            end
        else
            self:dropObject()
        end
    end
end

function Player:update(dt)
    local vx, vy = self.body:getLinearVelocity()
    local threshold = 50
    if love.keyboard.isDown("left") and vx > -50 then
        self:setFacingLeft(true)
        self.body:applyForce(-100, 0)
    end
    if love.keyboard.isDown("right") and vx < 50 then
        self:setFacingLeft(false)
        self.body:applyForce(100, 0)
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

    table.find_remove_one(self.objectsToPickup, self.pickedObject)

    self.pickedObject.isPicked = false
    self.pickedObject.isReachable = false
    self.pickedObject.body:setFixedRotation(false)
    self.pickedObject = nil
end

function Player:onCollisionBegin(other, coll)
    if other.pickable then
        local cx1, cy1, cx2, cy2 = coll:getPositions()
        local x, y = self.body:getPosition()
        if self.facingLeft then
            if cx1 and cx1 < x - self.width * 0.3 then
                other.isReachable = true
                table.insert(self.objectsToPickup, other)
            end
        else 
            if cx1 and cx1 > x + self.width * 0.3 then
                other.isReachable = true
                table.insert(self.objectsToPickup, other)
            end
        end
    end
    if other.ground then 
        local cx1, cy1, cx2, cy2 = coll:getPositions()
        local x, y = self.body:getPosition()
        if cy1 and cy1 > y + self.height * 0.3 then
            table.insert(self.objectsSteppingOn, other)
        end
    end 
end

function Player:onCollisionEnd(other, coll)
    if other.pickable then
        if table.find_remove_one(self.objectsToPickup, other) then
            other.isReachable = false
        end
    end
    if other.ground then
        table.find_remove_one(self.objectsSteppingOn, other)
    end
end
