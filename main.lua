require "strict"
serpent = require "serpent"
Object = require "classic"
Camera = require "Camera"
Timer = require "timer"

canvas = nil

fontchars = 'abcdefghijklmnopqrstuvwxyz"\'`-_/1234567890!?[](){}.,;:<>+=%#^*~ '
font = nil

debug = true

images = {}
world = nil
ship = nil
boxes = {}
player = nil
drones = {}
bullets = {}

camera = nil

Constants = {
    gravity = 9.81 * 25,
    waterDensity = 1
}

require "utils"

require "pickable"
require "ship"
require "bullet"
require "player"
require "box"
require "drone"

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
    images.player = love.graphics.newImage("images/player2.png")
    images.drone1 = love.graphics.newImage("images/drone1.png")
    images.bullet1 = love.graphics.newImage("images/bullet1.png")

    love.physics.setMeter(32)
    world = love.physics.newWorld(0, Constants.gravity)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    ship = Ship()
    for i=1,8 do
        boxes[i] = Box(i * 32 - 16, 0)
    end
    player = Player()

    drones[1] = Drone(64, 0)
    drones[2] = Drone(128, 0)
    drones[3] = Drone(196, 0)
    drones[4] = Drone(256, 0)

    camera = Camera(256, 256, 256, 256)
end

function love.update(dt)
    Timer.update(dt)

    world:update(dt)
    player:update(dt)
    ship:update(dt)
    for i = 1, #bullets do
        bullets[i]:update(dt)
    end
    for i = 1, #drones do
        drones[i]:update(dt)
    end

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

    for i = 1, #boxes do
        boxes[i]:draw()
    end
    player:draw()
    ship:draw()
    for i = 1, #bullets do
        bullets[i]:draw()
    end
    for i = 1, #drones do
        drones[i]:draw()
    end

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

    love.graphics.print("health: " .. player.health, 10, 10)

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
