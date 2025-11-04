local Shop = {}
Shop.__index = Shop

function Shop:new(game, onExit)
    local o = setmetatable({}, self)
    o.game = game
    o.onExit = onExit  -- función que se llama cuando el jugador sale de la tienda
    o.font = love.graphics.newFont(24)
    o.selected = nil
    o.fadeAlpha = 1
    o.fadeDir = -1
    o.options = {
        { name = "Aumentar rango de linterna (+10)", cost = 50, action = function()
            game.lightRadius = game.lightRadius + 10
        end },
        { name = "Más tiempo (+5s)", cost = 50, action = function()
            game.timeLeft = game.timeLeft + 5
        end },
        { name = "Ping de radar (muestra monstruos 1s)", cost = 75, action = function()
            game.hasRadarPing = true
        end }
    }
    return o
end

function Shop:update(dt)
    -- efecto de entrada/salida
    if o.fadeDir ~= 0 then
        o.fadeAlpha = o.fadeAlpha + o.fadeDir * dt
        if o.fadeAlpha < 0 then
            o.fadeAlpha = 0
            o.fadeDir = 0
        elseif o.fadeAlpha > 1 then
            o.fadeAlpha = 1
            o.fadeDir = 0
        end
    end
end

function Shop:draw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setFont(self.font)

    -- fondo oscuro
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, w, h)

    -- título
    love.graphics.setColor(1, 1, 1)
    local title = "TIENDA"
    local tw = self.font:getWidth(title)
    love.graphics.print(title, (w - tw) / 2, 80)

    -- mostrar puntuación
    local scoreText = "Puntos disponibles: " .. self.game.score
    love.graphics.print(scoreText, (w - self.font:getWidth(scoreText)) / 2, 130)

    -- dibujar opciones
    for i, opt in ipairs(self.options) do
        local y = 200 + (i - 1) * 80
        local x = w / 2 - 200
        local mx, my = love.mouse.getPosition()
        local hovered = mx > x and mx < x + 400 and my > y and my < y + 60

        if hovered then
            love.graphics.setColor(0.8, 0.8, 1)
        else
            love.graphics.setColor(0.6, 0.6, 0.6)
        end

        love.graphics.rectangle("line", x, y, 400, 60, 10)
        love.graphics.print(opt.name .. "  (" .. opt.cost .. ")", x + 20, y + 15)
    end

    -- botón continuar
    local btnText = "CONTINUAR"
    local bx, by = (w - 200) / 2, h - 120
    local mx, my = love.mouse.getPosition()
    local hovered = mx > bx and mx < bx + 200 and my > by and my < by + 60
    love.graphics.setColor(hovered and {0.8,1,0.8} or {0.7,0.7,0.7})
    love.graphics.rectangle("line", bx, by, 200, 60, 10)
    love.graphics.print(btnText, bx + 50, by + 15)
end

function Shop:mousepressed(x, y, button)
    if button ~= 1 then return end
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    -- comprobar opciones de compra
    for i, opt in ipairs(self.options) do
        local oy = 200 + (i - 1) * 80
        local ox = w / 2 - 200
        if x > ox and x < ox + 400 and y > oy and y < oy + 60 then
            if self.game.score >= opt.cost then
                self.game.score = self.game.score - opt.cost
                opt.action()
                love.audio.play(self.game.sndBuy or love.audio.newSource("assets/buy.wav", "static"))
            else
                love.audio.play(self.game.sndError or love.audio.newSource("assets/error.wav", "static"))
            end
        end
    end

    -- botón continuar
    local bx, by = (w - 200) / 2, h - 120
    if x > bx and x < bx + 200 and y > by and y < by + 60 then
        self.onExit() -- volver al juego
    end
end

return Shop
