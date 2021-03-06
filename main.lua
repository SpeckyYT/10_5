--[[
    Copyright Oliver Kjellén 2019
]]

--[[
    Entry point for the program. Requiring various files, setting a few global variables,
    setting screen resolution, effects and so on
]]--

--Shortening some keywords--
p = love.physics
g = love.graphics
k = love.keyboard

width = g.getWidth()
font = g.newFont("resources/jackeyfont.ttf", 64)
g.setFont(font)
--Do i even need to do this?--
math.randomseed(os.time())

--Requiring external modules--
--Great library, using it for cheatcodes on pause
konami = require("Konami.konami")
--Great library, using it for timers and tweening
Timer = require("hump.timer")
--Great library, using it for shaders
moonshine = require ("moonshine")

--Requiring internal modules--
require("state.stateHandler")
require("state.pause")
require("state.menu")
require("state.gameOver")
require("state.game")
require("scripts.util")
require("scripts.text")
require("scripts.speedrun")
require("scripts.soundHandler")
require("scripts.settingsChanger")
require("scripts.player")
require("scripts.moonshineFilters")
require("scripts.dataHandler")
require("scripts.curtain")
require("scripts.cheatCodes")
require("Levels.LevelHandler")

--End of requiring modules--

--Window Resolutions--
windowWidth = 1280
windowHeight = 720

love.window.setMode(windowWidth, windowHeight, {
    fullscreen = false,
    resizable = false,
    vsync = true,
    highdpi = true
})

--Sets the game icon--
love.window.setIcon(love.image.newImageData("resources/icon.png"))

--If playing for the first time init a save file--
if DataHandler:loadGame() == nil then
    DataHandler:init()
end

--Start at the menu state--
State.menu = true
State:menuStart()

--Loading various things at startup--
function love.load()
    effect = moonshine(moonshine.effects.crt).chain(moonshine.effects.dmg).chain(moonshine.effects.pixelate).chain(moonshine.effects.fastgaussianblur).chain(moonshine.effects.scanlines)
    effect.dmg.palette = "stark_bw"
    effect.scanlines.width = 2
    effect.scanlines.phase = 0
    effect.scanlines.thickness = 0.15
    effect.scanlines.opacity = 0.5
    effect.fastgaussianblur.offset = 2
    effect.fastgaussianblur.taps = 5
    effect.pixelate.size = 1
end

--Main update function--
function love.update(dt)
    Timer.update(dt)
    State:stateChanger(dt)
end


local screenChangeValue = 0
--Main draw function--
function love.draw()
    local w, h, f = love.window.getMode()
    s = love.graphics.getHeight() / windowHeight
    leftOffset = (w - (windowWidth * s)) / 2
    topOffset = (h - (windowHeight * s)) / 2
    love.graphics.push(love.graphics.translate(leftOffset, topOffset))
    love.graphics.scale(s)

    function love.keyreleased(key)
        if key == "f" then
            if screenChangeValue then
                love.window.setFullscreen(true, "desktop")
            else
                love.window.setFullscreen(false, "desktop")
            end
            screenChangeValue = not screenChangeValue
        end
     end

    effect(function()
        if not State.change then
            if State.game then
                Game:draw()
            end
            if State.menu then
                Menu:draw()
            end
            if State.paused then
                Pause:draw()
            end
            if State.gameOver then
                GameOver:draw()
            end
        end
        love.graphics.pop()
    end)
end
--This is used to resize the screen filters correctly
rw, rh, rf = love.window.getMode()
function love.resize(rw, rh)
    effect.disable(unpack(activeMoonshineFilters))
    effect.resize(rw, rh)
    effect.enable(unpack(activeMoonshineFilters))
end
