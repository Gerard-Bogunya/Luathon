-- src/ui.lua
local UI = {}
UI.__index = UI

function UI:new(game)
    local o = setmetatable({}, self)
    o.game = game
    o.font = love.graphics.newFont(16)
    return o
end

function UI:update(dt) end

function UI:draw()
    local g = self.game
    love.graphics.setFont(self.font)
    love.graphics.setColor(1,1,1)
    love.graphics.print("Nivel: " .. g.level, 10, 10)
    love.graphics.print("Puntuación: " .. g.score, 10, 30)
    love.graphics.print(string.format("Tiempo: %.1f", g.timeLeft), 10, 50)
    love.graphics.print("Atrapados: " .. g.caughtThisLevel .. " / " .. g.targetThisLevel, 10, 70)
end

return UI
