 --[[
        Copyright Oliver Kjellén 2019
    ]]

--[[Entry point for the program. Requiring various files, setting a few global variables,
    setting screen resolution, effects and so on]]--

--Shortening some keywords--
p = love.physics
g = love.graphics
k = love.keyboard

width = g.getWidth()
font = g.newFont("resources/jackeyfont.ttf", 64)
g.setFont(font)
--Do i even need to do this?--
math.randomseed(os.time())

--Requiring modules--
require("state.stateHandler")
require("state.menu")
require("state.game")
require("state.pause")
require("state.gameOver")
require("scripts.soundHandler")
require("scripts.player")
require("scripts.curtain")
require("scripts.settingsChanger")
require("scripts.text")
require("scripts.dataHandler")
require("Levels.LevelHandler")
--Great library, using it for timers and tweening--
Timer = require("hump.timer")
--[[Great library, using it as I haven't learned any shader coding yet
    Includes lots of shaders free to use]]--
local moonshine = require ("moonshine")
--End of requiring modules--

love.window.setMode( 1280, 720, {
    fullscreen = false,
    resizable = false,
    vsync = true,
    highdpi = true
} )

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
    s = love.graphics.getHeight() / 720
    leftOffset = (w - (1280 * s)) / 2
    topOffset = (h - (720 * s)) / 2  
    love.graphics.push(love.graphics.translate(leftOffset, topOffset))
    love.graphics.scale(s)

    function love.keyreleased(key)
        if key == "f" then
            if screenChangeValue % 2 ~= 0 then
                love.window.setFullscreen(false, "desktop")
            else
                love.window.setFullscreen(true, "desktop")
            end
            screenChangeValue = screenChangeValue + 1
        end
     end
    
    effect(function()
        if State.game == true and State.change == false then
            Game:draw()
        end
        if State.menu == true and State.change == false then
            Menu:draw()
        end
        if State.paused == true and State.change == false then
            Pause:draw()
        end
        if State.gameOver == true and State.change == false then
            GameOver:draw()
        end
        love.graphics.pop()    
    end)
end
--This is used to resize the screen filters correctly
rw, rh, rf = love.window.getMode()
function love.resize(rw, rh)
    effect.disable("crt", "dmg", "pixelate", "fastgaussianblur", "scanlines") 
    effect.resize(rw, rh)
    effect.enable("crt", "dmg", "pixelate", "fastgaussianblur", "scanlines")
end
