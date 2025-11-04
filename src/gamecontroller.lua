local UI = require("src.ui")
local Monster = require("src.monster")
local Boss = require("src.boss")
local Particles = require("src.particles")

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
    o.boss = nil
    o.ui = UI:new(o)
    o.particles = Particles:new()
    o:spawnMonsters()

    o.transitionAlpha = 0
    o.isTransitioning = false
    o.showMessage = nil
    o.transitionTimer = 0
    o.transitionCallback = nil
    o.returningToMenu = false

    o.onReturn = onReturn
    o.debugSkipPressed = false

    return o
end

-- 🟠 Spawning
function GameController:spawnMonsters()
    self.monsters = {}
    local w, h = love.graphics.getDimensions()

    if self.level == 5 then
        self.boss = Boss:new(w / 2, h / 2)
        for i = 1, 2 do
            local m = Monster(math.random(40, w - 40), math.random(40, h - 40), "triangle")
            m.onTrapped = function(x, y)
                self.particles:spawn(x, y, m.kind, m.color)
            end
            table.insert(self.monsters, m)
        end
        return
    else
        self.boss = nil
    end

    local total = self.targetThisLevel or 5
    local countNormal = math.floor(total * 0.75)
    local countTri = total - countNormal

    if self.level < 3 then
        countNormal = total
        countTri = 0
    end

    for i = 1, countNormal do
        local m = Monster(math.random(40, w - 40), math.random(40, h - 40), "normal")
        m.onTrapped = function(x, y)
            self.particles:spawn(x, y, m.kind, m.color)
        end
        table.insert(self.monsters, m)
    end

    for i = 1, countTri do
        local m = Monster(math.random(40, w - 40), math.random(40, h - 40), "triangle")
        m.onTrapped = function(x, y)
            self.particles:spawn(x, y, m.kind, m.color)
        end
        table.insert(self.monsters, m)
    end
end

-- 🕹️ Update
function GameController:update(dt)
    if self.state == "intro_enemy" then
        self:updateIntroEnemy(dt)
        return
    end
    if self.isTransitioning then
        self:updateTransition(dt)
        return
    end

    if self.state == "playing" then
        for _, m in ipairs(self.monsters) do
            m:update(dt)
        end
        if self.boss then
            self.boss:update(dt)
        end

        local trappedCount = 0
        for _, m in ipairs(self.monsters) do
            if m.state == "trapped" then
                trappedCount = trappedCount + 1
            end
        end
        if self.boss and self.boss.state == "trapped" then
            trappedCount = trappedCount + 1
        end
        self.caughtThisLevel = trappedCount

        if self.caughtThisLevel >= self.targetThisLevel then
            self:levelComplete()
        else
            if self.timeLeft > 0 then
                self.timeLeft = self.timeLeft - dt
                if self.timeLeft <= 0 then
                    self.timeLeft = 0
                    self:gameOver()
                end
            end
        end

        self.particles:update(dt)
    end
end

-- 🎨 Draw
function GameController:draw()
    local w, h = love.graphics.getDimensions()
    love.graphics.clear(0.05, 0.05, 0.07)

    if self.state == "intro_enemy" then
        self:drawIntroEnemy()
        return
    end

    if self.state == "playing" then
        if self.boss then
            self.boss:draw(true)
        end
        for _, m in ipairs(self.monsters) do
            m:draw(true)
        end

        self.particles:draw()

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
        self:drawUpgradeMenu()
    elseif self.state == "gameover" then
        self:drawGameOver()
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

-- 🖱️ Input
function GameController:mousepressed(x, y, button)
    if button ~= 1 then return end
    if self.state == "playing" then
        -- 👑 Boss click
        if self.boss and self.boss.state ~= "trapped" then
            if self.boss:containsPoint(x, y) then
                if self.boss.state == "weakened" then
                    self.boss.state = "trapped"
                    self.caughtThisLevel = self.caughtThisLevel + 1
                    self.score = self.score + 50
                    self.particles:spawn(x, y, "boss", {0.8, 0.1, 0.1})
                else
                    self.boss:hit()
                end
                return
            end
        end

        -- 🧟 Monsters click
        for _, m in ipairs(self.monsters) do
            if m.state ~= "trapped" and m:containsPoint(x, y) then
                if m.kind == "triangle" then
                    -- primer clic: enfurece y duplica velocidad
                    if not m.hitOnce then
                        m.hitOnce = true
                        m.color = {1, 0.5, 0} -- naranja
                        m.speed = m.speed * 2
                        return
                    end
                end

                -- segundo clic o normales
                m:trap()
                if m.onTrapped then
                    m.onTrapped(m.x, m.y)
                end
                self.caughtThisLevel = self.caughtThisLevel + 1
                self.score = self.score + 10
                break
            end
        end
    elseif self.state == "upgrade" then
        self:handleUpgradeClick(x, y)
    elseif self.state == "gameover" and self.gameOverButton then
        local b = self.gameOverButton
        if x >= b.x and x <= b.x + b.w and y >= b.y and y <= b.y + b.h then
            self:returnToMenu()
        end
    end
end


function GameController:keypressed(key)
    if key == "5" then
        self.level = 4
        self:startNextLevel()
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
        -- Restaurar el tamaño original de la ventana (ajusta a tu resolución base si hace falta)
        local flags = select(3, love.window.getMode())
        love.window.setMode(480, 360, flags)

        -- Reset valores básicos
        self.level = 1
        self.lightRadius = 100
        self.bonusLight = 0
        self.bonusTime = 0
        self.scoreMultiplier = 1

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
            text = "+2,5s Tiempo Extra", 
            apply = function(g)
                g.bonusTime = g.bonusTime + 2.5
                g.timeLeft = g.timeLeft + 2.5
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
    self.timeLeft = 10 + (self.level) + (self.bonusTime or 0)
    
    -- 🧩 Ajuste del número de enemigos
    if self.level == 5 then
        self.targetThisLevel = 3  -- solo 3 enemigos: boss + 2 triángulos
    else
        self.targetThisLevel = 5 + self.level
    end

    self.caughtThisLevel = 0

    -- 🪟 Ajuste del tamaño real según el nivel
    local baseW, baseH = 480, 360
    local growth = 80
    local w = baseW + (self.level - 1) * growth
    local h = baseH + math.floor((self.level - 1) * growth * 0.75)
    local _, _, flags = love.window.getMode()
    love.window.setMode(w, h, flags)

    self.lightRadius = 80 + (self.bonusLight or 0)
    self:spawnMonsters()

    -- 👇 Control de intros según nivel
    if self.level == 3 then
        self:showNewEnemyIntro()
    elseif self.level == 5 then
        self:showBossIntro()
    else
        self:continueLevelStart()
    end
end


-- =======================
-- 🟡 Intro nuevo enemigo
-- =======================
function GameController:showNewEnemyIntro()
    self.state = "intro_enemy"
    self.introType = "triangle"
    self.introTimer = 0
end

function GameController:showBossIntro()
    self.state = "intro_enemy"
    self.introType = "boss"
    self.introTimer = 0
end

function GameController:updateIntroEnemy(dt)
    self.introTimer = self.introTimer + dt
    if self.introTimer > 5 then
        self:continueLevelStart()
    end
end

function GameController:drawIntroEnemy()
    local w, h = love.graphics.getDimensions()
    local time = love.timer.getTime()
    local pulse = 1 + 0.15 * math.sin(time * 6)

    love.graphics.setColor(1, 1, 1)

    if self.introType == "triangle" then
        love.graphics.setFont(love.graphics.newFont(36))
        love.graphics.printf("¡Nuevo Enemigo!", 0, h * 0.25, w, "center")

        love.graphics.push()
        love.graphics.translate(w / 2, h * 0.5)
        love.graphics.scale(pulse)
        love.graphics.setColor(1, 0.9, 0.2)
        local size = 25
        love.graphics.polygon("fill", 0, -size, size * 0.8, size, -size * 0.8, size)
        love.graphics.setColor(0, 0, 0)
        love.graphics.polygon("line", 0, -size, size * 0.8, size, -size * 0.8, size)
        love.graphics.pop()

        love.graphics.setFont(love.graphics.newFont(20))
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(
            "Los triángulos requieren dos clics.\nTras el primero, se enfurecen y duplican su velocidad.",
            w * 0.1, h * 0.65, w * 0.8, "center"
        )

    elseif self.introType == "boss" then
    love.graphics.setFont(love.graphics.newFont(36))
    love.graphics.setColor(1, 0.3, 0.3)

    -- 🔹 Título un poco más arriba y centrado
    love.graphics.printf("¡Nuevo Jefe!", 0, h * 0.18, w, "center")

    -- 🔹 Boss centrado visualmente con efecto de latido
    love.graphics.push()
    love.graphics.translate(w / 2, h * 0.47)
    love.graphics.scale(pulse * 2.2)
    love.graphics.setColor(0.8, 0.1, 0.1)
    love.graphics.circle("fill", 0, 0, 40)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("line", 0, 0, 40)
    love.graphics.pop()

    -- 🔹 Descripción más abajo para que no se sobreponga al boss
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
        "Golpéalo 4 veces. Cada vez que lo hieres se hace más pequeño y se teletransporta.\n¡Cuando esté débil, podrás atraparlo!",
        w * 0.1, h * 0.7, w * 0.8, "center"
    )
end

end



-- =======================
-- 🔻 Game Over & Upgrade UI
-- =======================
function GameController:gameOver()
    self.state = "gameover"
end

function GameController:handleUpgradeClick(x, y)
    local w, h = love.graphics.getDimensions()
    local font = love.graphics.getFont()

    for i, up in ipairs(self.upgrades or {}) do
        local textWidth = font:getWidth(up.text)
        local textHeight = font:getHeight()
        local tx = (w / 2) - (textWidth / 2)
        local ty = h * 0.35 + (i - 1) * 80

        if x >= tx and x <= tx + textWidth and y >= ty and y <= ty + textHeight then
            up.apply(self)
            self:startNextLevel()
            return
        end
    end
end

function GameController:drawGameOver()
    local w, h = love.graphics.getDimensions()

    love.graphics.setFont(love.graphics.newFont(40))
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("GAME OVER", 0, h / 2 - 40, w, "center")

    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf("Puntuación total: " .. self.score, 0, h / 2 + 10, w, "center")

    love.graphics.setFont(love.graphics.newFont(20))
    local text = "Haz CLICK para volver al menú"
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight()
    local x = (w / 2) - (textWidth / 2)
    local y = h / 2 + 60

    local mx, my = love.mouse.getPosition()
    local hovered = mx >= x and mx <= x + textWidth and my >= y and my <= y + textHeight

    love.graphics.setColor(hovered and {1, 0.9, 0.3} or {1, 1, 1})
    love.graphics.print(text, x, y)

    self.gameOverButton = {x = x, y = y, w = textWidth, h = textHeight}
end

function GameController:drawUpgradeMenu()
    local w, h = love.graphics.getDimensions()
    love.graphics.setFont(love.graphics.newFont(32))
    local font = love.graphics.getFont()
    local mx, my = love.mouse.getPosition()

    love.graphics.setColor(0.4, 0.7, 1.0)
    love.graphics.printf("Elige una mejora", 0, h * 0.15, w, "center")

    for i, up in ipairs(self.upgrades) do
        local textWidth = font:getWidth(up.text)
        local textHeight = font:getHeight()
        local x = (w / 2) - (textWidth / 2)
        local y = h * 0.35 + (i - 1) * 80
        local hovered = mx >= x and mx <= x + textWidth and my >= y and my <= y + textHeight
        love.graphics.setColor(hovered and {1, 0.9, 0.3} or {1, 1, 1})
        love.graphics.print(up.text, x, y)
    end
end
function GameController:continueLevelStart()
    -- Cierra la intro y arranca la transición normal de inicio de nivel
    self.state = "playing"
    self.isTransitioning = true
    self.transitionAlpha = 1
    self.showMessage = "Expanding Area..."
    self.transitionTimer = 0
end

return GameController
