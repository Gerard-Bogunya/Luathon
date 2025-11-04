local UI = require("src.ui")

local GameController = {}
GameController.__index = GameController

function GameController:new(onReturn)
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
    o.transitionCallback = nil
    o.returningToMenu = false

    -- callback que se usará para volver al menú
    o.onReturn = onReturn

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

        if self.caughtThisLevel < self.targetThisLevel then
            if self.timeLeft > 0 then
                self.timeLeft = self.timeLeft - dt
                if self.timeLeft <= 0 then
                    self.timeLeft = 0
                    self:gameOver()
                end
            end
        end

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
        for _, m in ipairs(self.monsters) do
            if not m.caught then
                love.graphics.setColor(1, 0.3, 0.3)
                love.graphics.circle("fill", m.x, m.y, m.r)
            else
                love.graphics.setColor(0.4, 0.7, 1.0)
                love.graphics.rectangle("fill", m.x - m.r, m.y - m.r, m.r * 2, m.r * 2)
            end
        end

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

    -- 🟦 Texto del título "Elige una mejora" más arriba y color azul suave
    love.graphics.setColor(0.4, 0.7, 1.0) -- azul clarito
    love.graphics.printf("Elige una mejora", 0, h * 0.15, w, "center")  -- antes estaba 0.25

    -- 🔹 Dibuja las mejoras con más separación
    for i, up in ipairs(self.upgrades) do
        local textWidth = font:getWidth(up.text)
        local textHeight = font:getHeight()
        local x = (w / 2) - (textWidth / 2)
        local y = h * 0.35 + (i - 1) * 80  -- más separación vertical (antes era 0.4 y 80)
        local hovered = mx >= x and mx <= x + textWidth and my >= y and my <= y + textHeight
        love.graphics.setColor(hovered and {1, 0.9, 0.3} or {1, 1, 1})
        love.graphics.print(up.text, x, y)
    end


    elseif self.state == "gameover" then
        love.graphics.setFont(love.graphics.newFont(40))
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("GAME OVER", 0, h / 2 - 40, w, "center")
        love.graphics.setFont(love.graphics.newFont(24))
        love.graphics.printf("Puntuación total: " .. self.score, 0, h / 2 + 10, w, "center")

        love.graphics.setFont(love.graphics.newFont(20))
        local text = "Haz CLICK para volver al menú"
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(text)
        local x = (w / 2) - (textWidth / 2)
        local y = h / 2 + 60
        local mx, my = love.mouse.getPosition()
        local hovered = mx >= x and mx <= x + textWidth and my >= y and my <= y + font:getHeight()
        love.graphics.setColor(hovered and {1, 0.9, 0.3} or {1, 1, 1})
        love.graphics.print(text, x, y)
        self.gameOverButton = {x = x, y = y, w = textWidth, h = font:getHeight()}
    end

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
            local tx = (w / 2) - (textWidth / 2)
            local ty = h * 0.4 + (i - 1) * 80

            if x >= tx and x <= tx + textWidth and y >= ty and y <= ty + textHeight then
                up.apply(self)
                self:startNextLevel()  -- inicia el siguiente nivel tras aplicar
                return
            end
        end
    
        local w, h = love.graphics.getDimensions()
        local font = love.graphics.getFont()
        for i, up in ipairs(self.upgrades) do
            local textWidth = font:getWidth(up.text)
            local textHeight = font:getHeight()
            local tx = (w / 2) - (textWidth / 2)
            local ty = h * 0.4 + (i - 1) * 80
            if x >= tx and x <= tx + textWidth and y >= ty and y <= ty + textHeight then
                up.apply(self)
                self:startNextLevel()
                break
            end
        end

    elseif self.state == "gameover" and self.gameOverButton then
        local b = self.gameOverButton
        if x >= b.x and x <= b.x + b.w and y >= b.y and y <= b.y + b.h then
            self:returnToMenu()
        end
    end
end

-- =======================
-- 🔹 Transiciones
-- =======================
function GameController:returnToMenu()
    self.isTransitioning = true
    self.transitionAlpha = 1
    self.transitionTimer = 1
    self.showMessage = "Volviendo al menú..."
    self.transitionCallback = function()
        self.returningToMenu = true
    end
end

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
        self.transitionAlpha = math.min(1, self.transitionTimer)
    elseif self.transitionTimer < 2 then
        self.transitionAlpha = 1
    elseif self.transitionTimer < 3 then
        self.transitionAlpha = math.max(0, 3 - self.transitionTimer)
        if self.transitionCallback and self.transitionTimer > 2.9 then
            self.transitionCallback()
            self.transitionCallback = nil
            self.isTransitioning = false
            self.transitionTimer = 0
            self.transitionAlpha = 0
        elseif self.showMessage == "Level Complete!" and self.transitionTimer > 2.9 then
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

    -- al terminar transición de volver al menú
    if self.returningToMenu then
        if self.onReturn then
            self.onReturn()
        end
        self.returningToMenu = false
    end
end

function GameController:openUpgradeMenu()
    self.state = "upgrade"
    self.isTransitioning = false
    self.transitionAlpha = 0

    -- Inicializamos valores persistentes si no existen
    self.scoreMultiplier = self.scoreMultiplier or 1
    self.bonusLight = self.bonusLight or 0
    self.bonusTime = self.bonusTime or 0

    self.upgrades = {
        { 
            text = "+15 Rango de Luz", 
            apply = function(g)
                g.bonusLight = g.bonusLight + 15
                g.lightRadius = g.lightRadius + 15
            end
        },
        { 
            text = "+5s Tiempo Extra", 
            apply = function(g)
                g.bonusTime = g.bonusTime + 5
                g.timeLeft = g.timeLeft + 5
            end
        },
        { 
            text = "+10% dificultad (+10%pt)", 
            apply = function(g)
                g.scoreMultiplier = g.scoreMultiplier * 1.1
                for _, m in ipairs(g.monsters) do
                    m.speed = m.speed * 1.1
                end
            end
        }
    }
end


function GameController:startNextLevel()
    self.level = self.level + 1
    self.timeLeft = 10 + (self.level * 3) + (self.bonusTime or 0)
    self.targetThisLevel = 5 + self.level
    self.caughtThisLevel = 0

    local w, h, flags = love.window.getMode()
    local growth = 80
    love.window.setMode(w + growth, h + math.floor(growth * 0.75), flags)

    self.lightRadius = 80 + (self.bonusLight or 0)
    self:spawnMonsters()

    self.state = "playing"
    self.isTransitioning = true
    self.transitionAlpha = 1
    self.showMessage = "Expanding Area..."
    self.transitionTimer = 0
end


function GameController:gameOver()
    self.state = "gameover"
end

return GameController
