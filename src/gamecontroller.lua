-- src/gamecontroller.lua
local UI = require("src.ui")

local GameController = {}
GameController.__index = GameController

function GameController:new()
    local o = setmetatable({}, self)
    o.level = 1
    o.score = 0
    o.timeLeft = 30
    o.caughtThisLevel = 0
    o.targetThisLevel = 5
    o.lightRadius = 100
    o.state = "playing"

    o.monsters = {}
    o.ui = UI:new(o)
    o:spawnMonsters()

    return o
end

-- =======================
-- 🔹 Spawning de enemigos
-- =======================
function GameController:spawnMonsters()
    self.monsters = {}
    for i = 1, self.targetThisLevel do
        table.insert(self.monsters, {
            x = math.random(60, love.graphics.getWidth() - 60),
            y = math.random(60, love.graphics.getHeight() - 60),
            r = 15,
            caught = false,
            speed = (100 + math.random(0, 40)) + (self.level * 10), -- más rápido con el nivel
            dir = math.random() * math.pi * 2,
            changeDirTimer = math.random() * 2
        })
    end
end

-- =======================
-- 🔹 Actualización
-- =======================
function GameController:update(dt)
    if self.isTransitioning then
        self:updateTransition(dt)
        return
    end

    -- Movimiento natural
    for _, m in ipairs(self.monsters) do
        if not m.caught then
            m.changeDirTimer = m.changeDirTimer - dt
            if m.changeDirTimer <= 0 then
                m.dir = math.random() * math.pi * 2
                m.changeDirTimer = 0.5 + math.random() * 1.5
            end

            m.x = m.x + math.cos(m.dir) * m.speed * dt
            m.y = m.y + math.sin(m.dir) * m.speed * dt

            -- Mantener dentro de pantalla
            if m.x < m.r or m.x > love.graphics.getWidth() - m.r then
                m.dir = math.pi - m.dir
            end
            if m.y < m.r or m.y > love.graphics.getHeight() - m.r then
                m.dir = -m.dir
            end
        end
    end

    -- Tiempo y niveles
    if self.timeLeft > 0 and self.caughtThisLevel < self.targetThisLevel then
        self.timeLeft = self.timeLeft - dt
        if self.timeLeft <= 0 then
            self:gameOver()
        end
    end

    if self.caughtThisLevel >= self.targetThisLevel then
        self:levelComplete()
    end
end

-- =======================
-- 🔹 Dibujo
-- =======================
function GameController:draw()
    local w, h = love.graphics.getDimensions()
    love.graphics.clear(0.05, 0.05, 0.07)

    -- === Dibujo de enemigos ===
    for _, m in ipairs(self.monsters) do
        if not m.caught then
            love.graphics.setColor(1, 0.3, 0.3) -- rojo (enemigo libre)
            love.graphics.circle("fill", m.x, m.y, m.r)
        else
            love.graphics.setColor(0.4, 0.7, 1.0) -- azul claro (enemigo atrapado)
            love.graphics.rectangle("fill", m.x - m.r, m.y - m.r, m.r * 2, m.r * 2)
        end
    end

    -- === Oscuridad con agujero de luz ===
    local mx, my = love.mouse.getPosition()
    love.graphics.stencil(function()
        love.graphics.circle("fill", mx, my, self.lightRadius)
    end, "replace", 1)

    love.graphics.setStencilTest("equal", 0)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setStencilTest()

    -- === UI ===
    self.ui:draw()
end

-- =======================
-- 🔹 Input
-- =======================
function GameController:mousepressed(x, y, button)
    if self.state ~= "playing" or button ~= 1 then return end
    for _, m in ipairs(self.monsters) do
        if not m.caught then
            local dx, dy = m.x - x, m.y - y
            if dx * dx + dy * dy <= (m.r * m.r) then
                m.caught = true
                self.caughtThisLevel = self.caughtThisLevel + 1
                self.score = self.score + 10
                break
            end
        end
    end
end

-- =======================
-- 🔹 Lógica de niveles
-- =======================
function GameController:levelComplete()
    self.score = self.score + math.floor(self.timeLeft * 10)
    self.level = self.level + 1
    self.timeLeft = 30 + (self.level * 3)
    self.targetThisLevel = 5 + self.level
    self.caughtThisLevel = 0
    self:spawnMonsters()

    -- === Aumentar progresivamente el tamaño de la ventana ===
    local w, h, flags = love.window.getMode()
    local growth = 70  -- cuanto crece por nivel

    local newW = w + growth
    local newH = h + math.floor(growth * 0.75)

    -- límite máximo: no superar el tamaño del escritorio
    local desktopW, desktopH = love.window.getDesktopDimensions()
    if newW > desktopW * 0.95 then newW = desktopW * 0.95 end
    if newH > desktopH * 0.9 then newH = desktopH * 0.9 end

    love.window.setMode(newW, newH, flags)
end


function GameController:gameOver()
    print("GAME OVER - Puntuación total: " .. self.score)
    gameState = "menu"
end

return GameController
