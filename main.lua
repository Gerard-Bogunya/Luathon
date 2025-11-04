local Menu = require("src.menu")
local GameController = require("src.gamecontroller")

local currentScene = nil

function love.load()
    math.randomseed(os.time())
    love.window.setMode(480, 360, { resizable = false })

    local function start()
        local function backToMenu()
            currentScene = Menu:new(start)
        end
        currentScene = GameController:new(backToMenu)
    end

    currentScene = Menu:new(start)
end

function love.update(dt)
    if currentScene and currentScene.update then
        currentScene:update(dt)
    end
end

function love.draw()
    if currentScene and currentScene.draw then
        currentScene:draw()
    end
end

function love.mousepressed(x, y, button)
    if currentScene and currentScene.mousepressed then
        currentScene:mousepressed(x, y, button)
    end
end

function love.keypressed(key)
    if currentScene and currentScene.keypressed then
        currentScene:keypressed(key)
    end
end
