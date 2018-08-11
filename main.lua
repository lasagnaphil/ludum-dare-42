require "strict"
Object = require "classic"

local fontchars = 'abcdefghijklmnopqrstuvwxyz"\'`-_/1234567890!?[](){}.,;:<>+=%#^*~ '
local font

local debug = false

local images = {}
local world = nil
local ship = nil
local boxes = {}
local player = nil
local gravity = 9.81 * 10

function table.find_index(tbl, elem)
    for i, e in ipairs(tbl) do
        if e == elem then return i end
    end
    return nil
end

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

Box = Object:extend()

function Box:new(x, y)
    self.image = images.box
    self.size = images.box:getWidth()
    self.ground = true;
    self.body = love.physics.newBody(world, x, y, "dynamic")
    local box_shape = love.physics.newRectangleShape(self.size, self.size)
    self.fixture = love.physics.newFixture(self.body, box_shape, 1)
    self.fixture:setUserData(self)
end

function Box:draw()
    local x, y = self.body:getPosition()
    love.graphics.draw(self.image, x, y, self.body:getAngle(), 1, 1, self.size/2, self.size/2)
end

Player = Object:extend()

function Player:new()
    self.image = images.player
    self.width = images.player:getWidth()
    self.height = images.player:getHeight()
    self.facingLeft = false
    self.onGround = false
    self.objectsSteppingOn = {}
    self.body = love.physics.newBody(world, 128, 128, "dynamic")
    self.body:setFixedRotation(true)
    local shape = love.physics.newRectangleShape(0, 0, self.width, self.height)
    self.fixture = love.physics.newFixture(self.body, shape, 1)
    self.fixture:setUserData(self)
end

function Player:keypressed(key, scancode, isrepeat)
    if key == "up" then
        if #self.objectsSteppingOn > 0 then
            self.body:applyLinearImpulse(0, -50)
        end
    end
end

function Player:update(dt)
    local vx, vy = self.body:getLinearVelocity()
    local threshold = 50
    self.facingLeft = vx < 0
    if love.keyboard.isDown("left") and vx > -50 then
        self.body:applyForce(-100, 0)
    end
    if love.keyboard.isDown("right") and vx < 50 then
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

function Player:onCollisionBegin(other, coll)
    if other.ground then 
        local cx1, cy1, cx2, cy2 = coll:getPositions()
        local x, y = self.body:getPosition()
        if cy1 and cy1 > y + self.height * 0.3 then
            table.insert(self.objectsSteppingOn, other)
            print("begin stepping on object")
        end
    end 
end

function Player:onCollisionEnd(other, coll)
    if other.ground then
        local index = table.find_index(self.objectsSteppingOn, other) 
        if index then
            table.remove(self.objectsSteppingOn, index)
            print("end stepping on object")
        end
    end
end

function love.load()
    love.window.setMode(512, 512, {})
    font = love.graphics.newImageFont("pico8_font.png", fontchars, 1)
    font:setFilter("nearest", "nearest")
    love.graphics.setFont(font)
    love.graphics.setDefaultFilter("nearest", "nearest", 1)

    images.ocean = love.graphics.newImage("ocean.png")
    images.background = love.graphics.newImage("background.png")
    images.ship = love.graphics.newImage("ship.png")
    images.box = love.graphics.newImage("box.png")
    images.player = love.graphics.newImage("player_small.png")

    love.physics.setMeter(32)
    world = love.physics.newWorld(0, gravity)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    ship = Ship()
    for i=1,8 do
        boxes[i] = Box(i * 32 - 16, 0)
    end
    player = Player()
end

function love.update(dt)
    world:update(dt)
    player:update(dt)
    ship:update(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(2, 2)
    love.graphics.draw(images.background)
    for _, box in ipairs(boxes) do
        box:draw()
    end
    player:draw()
    ship:draw()
    love.graphics.draw(images.ocean)

    if debug then
        love.graphics.setColor(0, 1, 0)
        for _, body in pairs(world:getBodies()) do
            for _, fixture in pairs(body:getFixtures()) do
                local shape = fixture:getShape()
                if shape:typeOf("CircleShape") then
                    local cx, cy = body:getWorldPoints(shape:getPoint())
                    love.graphics.circle("line", cx, cy, shape:getRadius())
                elseif shape:typeOf("PolygonShape") then
                    love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))
                else
                    love.graphics.line(body:getWorldPoints(shape:getPoints()))
                end
            end
        end
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.pop()
end

function love.keypressed(key, scancode, isrepeat)
    player:keypressed(key, scancode, isrepeat)
    if key == "f1" then
        debug = not debug
    end
end

function beginContact(a_fixture, b_fixture, coll)
    local a = a_fixture:getUserData()
    local b = b_fixture:getUserData()
    if a and a.onCollisionBegin then
        a:onCollisionBegin(b, coll)
    end
    if b and b.onCollisionBegin then
        b:onCollisionBegin(a, coll)
    end
end
 
function endContact(a_fixture, b_fixture, coll)
    local a = a_fixture:getUserData()
    local b = b_fixture:getUserData()
    if a and a.onCollisionEnd then
        a:onCollisionEnd(b, coll)
    end
    if b and b.onCollisionEnd then
        b:onCollisionEnd(a, coll)
    end
end
 
function preSolve(a, b, coll)
end
 
function postSolve(a, b, coll, normalImpulse, tangentImpulse)
end
