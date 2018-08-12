require "strict"
serpent = require "serpent"
Object = require "classic"
Camera = require "Camera"

canvas = nil

fontchars = 'abcdefghijklmnopqrstuvwxyz"\'`-_/1234567890!?[](){}.,;:<>+=%#^*~ '
font = nil

debug = true

images = {}
world = nil
ship = nil
boxes = {}
player = nil
camera = nil

Constants = {
    gravity = 9.81 * 10,
    waterDensity = 1
}

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

function table.clear(tbl)
    for i in pairs(tbl) do
        tbl[i] = nil
    end
end

function table.insert_many(tbl, ...)
    for _, v in ipairs({...}) do
        tbl[#tbl + 1] = v
    end
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

function computeSunkVertices(polygonVertices, yb)
    local vertices = {}
    local x1, y1, x2, y2
    x2 = polygonVertices[#polygonVertices - 1]
    y2 = polygonVertices[#polygonVertices]
    for i=1, #polygonVertices do
        if i % 2 == 1 then
            x1 = x2
            x2 = polygonVertices[i]
        elseif i % 2 == 0 then
            y1 = y2
            y2 = polygonVertices[i]
            if y1 > yb and y2 > yb then
                table.insert_many(vertices, x2, y2)
            elseif y1 < yb and y2 > yb then
                local xb = x1 + (yb - y1) / (y2 - y1) * (x2 - x1)
                table.insert_many(vertices, xb, yb, x2, y2)
            elseif y1 > yb and y2 < yb then
                local xb = x2 + (yb - y2) / (y1 - y2) * (x1 - x2)
                table.insert_many(vertices, xb, yb)
            end
        end
    end
    if #vertices < 6 then return nil end
    return vertices
end

function computeCentroid(vertices)
    local cx, cy = 0, 0
    local area = 0
    local x1, y1, x2, y2
    x2 = vertices[#vertices - 1]
    y2 = vertices[#vertices]
    for i=1, #vertices do
        if i % 2 == 1 then
            x1 = x2
            x2 = vertices[i]
        elseif i % 2 == 0 then
            y1 = y2
            y2 = vertices[i]
            local cross = x1 * y2 - x2 * y1
            cx = cx + (x1 + x2) * cross
            cy = cy + (y1 + y2) * cross
            area = area + cross
        end
    end
    area = area / 2
    cx = cx / (6 * area)
    cy = cy / (6 * area)
    return cx, cy, area
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
    love.graphics.setDefaultFilter("nearest", "nearest")
    canvas = love.graphics.newCanvas(256, 256)

    images.ocean = love.graphics.newImage("images/ocean.png")
    images.background = love.graphics.newImage("images/background.png")
    images.ship = love.graphics.newImage("images/ship.png")
    images.box = love.graphics.newImage("images/box.png")
    images.player = love.graphics.newImage("images/player_small.png")

    love.physics.setMeter(32)
    world = love.physics.newWorld(0, Constants.gravity)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    ship = Ship()
    for i=1,8 do
        boxes[i] = Box(i * 32 - 16, 0)
    end
    player = Player()

    camera = Camera(256, 256, 256, 256)
end

function love.update(dt)
    world:update(dt)
    player:update(dt)
    ship:update(dt)

    camera:update(dt)
    camera:setFollowLerp(0.2)
    local x, y = player.body:getPosition()
    camera:follow(x, 128)

    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    -- draw the game

    love.graphics.draw(images.background)

    camera:attach()

    for _, box in ipairs(boxes) do
        box:draw()
    end
    player:draw()
    ship:draw()

    if debug then
        love.graphics.setColor(0, 1, 0)
        for _, body in pairs(world:getBodies()) do
            for _, fixture in pairs(body:getFixtures()) do
                drawHighlight(fixture, body)
            end
        end
        love.graphics.setColor(1, 1, 1)
    end

    camera:detach()

    love.graphics.draw(images.ocean)

    love.graphics.setCanvas()

    -- Draw the 512x512 canvas
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(canvas, 0, 0, 0, 2, 2)
    love.graphics.setBlendMode('alpha')
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
