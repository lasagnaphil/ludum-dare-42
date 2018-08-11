require "strict"
Object = require "classic"

fontchars = 'abcdefghijklmnopqrstuvwxyz"\'`-_/1234567890!?[](){}.,;:<>+=%#^*~ '
font = nil

debug = false

images = {}
world = nil
ship = nil
boxes = {}
player = nil

gravity = 9.81 * 10

function table.find_remove_one(tbl, elem)
    for i, e in ipairs(tbl) do
        if e == elem then 
            table.remove(tbl, i)
            return true
        end
    end
    return false
end

function table.find_index(tbl, elem)
    for i, e in ipairs(tbl) do
        if e == elem then return i end
    end
    return nil
end

function drawHighlight(fixture, body)
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

require "pickable"
require "ship"
require "player"

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

function love.load()
    love.window.setMode(512, 512, {})
    font = love.graphics.newImageFont("images/pico8_font.png", fontchars, 1)
    font:setFilter("nearest", "nearest")
    love.graphics.setFont(font)
    love.graphics.setDefaultFilter("nearest", "nearest", 1)

    images.ocean = love.graphics.newImage("images/ocean.png")
    images.background = love.graphics.newImage("images/background.png")
    images.ship = love.graphics.newImage("images/ship.png")
    images.box = love.graphics.newImage("images/box.png")
    images.player = love.graphics.newImage("images/player_small.png")

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
                drawHighlight(fixture:getShape())
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
