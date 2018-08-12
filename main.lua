require "deps.strict"
serpent = require "deps.serpent"
Object = require "deps.classic"
Camera = require "deps.Camera"
Timer = require "deps.timer"

require "utils"

require "title"
require "game"

canvas = nil

fontchars = 'abcdefghijklmnopqrstuvwxyz"\'`-_/1234567890!?[](){}.,;:<>+=%#^*~ '
font = nil

debug = true

images = {}

state = nil
nextState = nil

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
    images.drones = {
        love.graphics.newImage("images/drone1.png")
    }
    images.bullets = {
        love.graphics.newImage("images/bullet1.png")
    }
    images.turrets = {
        love.graphics.newImage("images/turret1.png")
    }

    state = Title()
end

function love.update(dt)
    if nextState ~= nil then
        state = nextState
        nextState = nil
    end

    Timer.update(dt)

    state:update(dt)

    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    state:draw()

    love.graphics.setCanvas()
    
    -- Draw the 512x512 canvas
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(canvas, 0, 0, 0, 2, 2)
    love.graphics.setBlendMode('alpha')
end

function love.keypressed(key, scancode, isrepeat)
    state:keypressed(key, scancode, isrepeat)
end
