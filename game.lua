world = nil
ship = nil
boxes = {}
player = nil
drones = {}
bullets = {}
turrets = {}

camera = nil

Constants = {
    gravity = 9.81 * 25,
    waterDensity = 1
}

require "pickable"
require "ship"
require "bullet"
require "player"
require "box"
require "drone"
require "turret"

Game = Object:extend()

function Game:new()
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

    turrets[1] = Turret(128, 20)
end

function Game:update(dt)
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

function Game:draw()
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
    for i = 1, #turrets do
        turrets[i]:draw()
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
end

function Game:keypressed(key, scancode, isrepeat)
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
 
function preSolve(a_fixture, b_fixture, coll)
    local a = a_fixture:getUserData()
    local b = b_fixture:getUserData()
    if a and a.onCollisionPresolve then
        a:onCollisionPresolve(b, coll)
    end
    if b and b.onCollisionPresolve then
        b:onCollisionPresolve(a, coll)
    end
end
 
function postSolve(a_fixture, b_fixture, coll, normalImpulse, tangentImpulse)
    local a = a_fixture:getUserData()
    local b = b_fixture:getUserData()
    if a and a.onCollisionPostsolve then
        a:onCollisionPostsolve(b, coll, normalImpulse, tangentImpulse)
    end
    if b and b.onCollisionPostsolve then
        b:onCollisionPostsolve(a, coll, normalImpulse, tangentImpulse)
    end
end
