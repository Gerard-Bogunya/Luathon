-- src/gamecontroller.lua
local UI = require("src.ui")

local GameController = {}
GameController.__index = GameController

function GameController:new()
    local o = setmetatable({}, self)
    o.level = 1
    o.score = 0
    o.timeLeft = 10
    o.caughtThisLevel = 0
    o.targetThisLevel = 5
    o.lightRadius = 100
    o.state = "playing"

    o.monsters = {}
    o.ui = UI:new(o)
    o:spawnMonsters()

    o.transitionAlpha = 0
    o.isTransitioning = false
    o.showMessage = nil
    o.transitionTimer = 0

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
            speed = (100 + math.random(0, 40)) + (self.level * 10),
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

    if self.state == "playing" then
        -- movimiento enemigo
        for _, m in ipairs(self.monsters) do
            if not m.caught then
                m.changeDirTimer = m.changeDirTimer - dt
                if m.changeDirTimer <= 0 then
                    m.dir = math.random() * math.pi * 2
                    m.changeDirTimer = 0.5 + math.random() * 1.5
                end

                m.x = m.x + math.cos(m.dir) * m.speed * dt
                m.y = m.y + math.sin(m.dir) * m.speed * dt

                if m.x < m.r then m.x, m.dir = m.r, math.pi - m.dir end
                if m.x > love.graphics.getWidth() - m.r then m.x, m.dir = love.graphics.getWidth() - m.r, math.pi - m.dir end
                if m.y < m.r then m.y, m.dir = m.r, -m.dir end
                if m.y > love.graphics.getHeight() - m.r then m.y, m.dir = love.graphics.getHeight() - m.r, -m.dir end
            end
        end

        -- tiempo
      if self.caughtThisLevel < self.targetThisLevel then
        if self.timeLeft > 0 then
            self.timeLeft = self.timeLeft - dt
            if self.timeLeft <= 0 then
                self.timeLeft = 0 -- evita negativos
                self:gameOver()
            end
        end
    end

        -- completar nivel
        if self.caughtThisLevel >= self.targetThisLevel then
            self:levelComplete()
        end
    end
end

-- =======================
-- 🔹 Dibujo
-- =======================
function GameController:draw()
    local w, h = love.graphics.getDimensions()
    love.graphics.clear(0.05, 0.05, 0.07)

    if self.state == "playing" then
        -- enemigos
        for _, m in ipairs(self.monsters) do
            if not m.caught then
                love.graphics.setColor(1, 0.3, 0.3)
                love.graphics.circle("fill", m.x, m.y, m.r)
            else
                love.graphics.setColor(0.4, 0.7, 1.0)
                love.graphics.rectangle("fill", m.x - m.r, m.y - m.r, m.r * 2, m.r * 2)
            end
        end

        -- oscuridad y linterna
        local mx, my = love.mouse.getPosition()
        love.graphics.stencil(function()
            love.graphics.circle("fill", mx, my, self.lightRadius)
        end, "replace", 1)
        love.graphics.setStencilTest("equal", 0)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle("fill", 0, 0, w, h)
        love.graphics.setStencilTest()

        self.ui:draw()

    elseif self.state == "upgrade" then
        love.graphics.setFont(love.graphics.newFont(32))
        local font = love.graphics.getFont()
        local mx, my = love.mouse.getPosition()

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Elige una mejora", 0, h * 0.25, w, "center")

        for i, up in ipairs(self.upgrades) do
            local textWidth = font:getWidth(up.text)
            local textHeight = font:getHeight()
            local x = (w / 2) - (textWidth / 2)
            local y = h * 0.4 + (i - 1) * 80

            local hovered = mx >= x and mx <= x + textWidth and my >= y and my <= y + textHeight

            love.graphics.setColor(hovered and {1, 0.9, 0.3} or {1, 1, 1})
            love.graphics.print(up.text, x, y)
        end
    end

    -- fundido
    if self.transitionAlpha > 0 then
        love.graphics.setColor(0, 0, 0, self.transitionAlpha)
        love.graphics.rectangle("fill", 0, 0, w, h)
        if self.showMessage then
            love.graphics.setColor(1, 1, 1, self.transitionAlpha)
            love.graphics.setFont(love.graphics.newFont(32))
            love.graphics.printf(self.showMessage, 0, h / 2 - 16, w, "center")
        end
    end
end

-- =======================
-- 🔹 Input
-- =======================
function GameController:mousepressed(x, y, button)
    if button ~= 1 then return end

    if self.state == "playing" then
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

    elseif self.state == "upgrade" then
        local w, h = love.graphics.getDimensions()
        local font = love.graphics.getFont()
        for i, up in ipairs(self.upgrades) do
            local textWidth = font:getWidth(up.text)
            local textHeight = font:getHeight()
            local x = (w / 2) - (textWidth / 2)
            local y = h * 0.4 + (i - 1) * 80
            if x <= love.mouse.getX() and love.mouse.getX() <= x + textWidth
               and y <= love.mouse.getY() and love.mouse.getY() <= y + textHeight then
                up.apply(self)
                self:startNextLevel()
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
    self.showMessage = "Level Complete!"
    self.isTransitioning = true
    self.transitionAlpha = 0
    self.transitionTimer = 0
end
function GameController:updateTransition(dt)
    self.transitionTimer = self.transitionTimer + dt

    if self.transitionTimer < 1 then
        -- fundido de entrada (pantalla oscurece)
        self.transitionAlpha = math.min(1, self.transitionTimer)
    elseif self.transitionTimer < 2 then
        -- pantalla totalmente negra, muestra texto
        self.transitionAlpha = 1
    elseif self.transitionTimer < 3 then
        -- fundido de salida (vuelve a iluminar)
        self.transitionAlpha = math.max(0, 3 - self.transitionTimer)

        -- Cuando el fundido termina (se vuelve transparente)
        if self.showMessage == "Level Complete!" and self.transitionTimer > 2.9 then
            self:openUpgradeMenu()
            self.isTransitioning = false
            self.transitionTimer = 0
            self.transitionAlpha = 0
        elseif self.showMessage == "Expanding Area..." and self.transitionTimer > 2.9 then
            self.isTransitioning = false
            self.transitionTimer = 0
            self.transitionAlpha = 0
            self.showMessage = nil
        end
    end
end

function GameController:openUpgradeMenu()
    self.state = "upgrade"
    self.isTransitioning = false
    self.transitionAlpha = 0
    self.upgrades = {
        { text = "+15 Rango de Luz", apply = function(g) g.lightRadius = g.lightRadius + 15 end },
        { text = "+5s Tiempo Extra", apply = function(g) g.timeLeft = g.timeLeft + 5 end },
        { text = "+10% Velocidad Enemigos (más reto)", apply = function(g)
            for _, m in ipairs(g.monsters) do
                m.speed = m.speed * 1.1
            end
        end }
    }
end

function GameController:startNextLevel()
    self.level = self.level + 1
    self.timeLeft = 30 + (self.level * 3)
    self.targetThisLevel = 5 + self.level
    self.caughtThisLevel = 0

    -- expandir área
    local w, h, flags = love.window.getMode()
    local growth = 70
    love.window.setMode(w + growth, h + math.floor(growth * 0.75), flags)

    self:spawnMonsters()
    self.state = "playing"
    self.isTransitioning = true
    self.transitionAlpha = 1
    self.showMessage = "Expanding Area..."
    self.transitionTimer = 0
end

function GameController:gameOver()
    print("GAME OVER - Puntuación total: " .. self.score)
    gameState = "menu"
end

return GameController
