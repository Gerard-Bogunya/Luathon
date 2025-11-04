local Menu = {}
Menu.__index = Menu

function Menu:new(onPlay)
    local o = setmetatable({}, self)
    o.onPlay = onPlay

    o.logo = love.graphics.newImage("src/assets/title.png")
    o.logoW, o.logoH = o.logo:getDimensions()

    local w, h = love.graphics.getDimensions()
    o.font = love.graphics.newFont(32)

    -- posiciones centradas
    o.buttons = {
        { text = "JUGAR", y = h * 0.6, action = "play" },
        { text = "SALIR", y = h * 0.7, action = "quit" }
    }

    -- luz giratoria
    o.angle = 20
    o.orbitRadiusX = 140
    o.orbitRadiusY = 30
    o.lightRadius = 80
    o.hover = nil

    -- ✅ valores iniciales por si draw() se llama antes de update()
    local cx, cy = w / 2, h * 0.35
    o.lightX = cx
    o.lightY = cy

    return o
end


function Menu:update(dt)
    self.angle = self.angle + dt * 0.9
    local w, h = love.graphics.getDimensions()
    local cx, cy = w / 2, h * 0.35
    self.lightX = cx + math.cos(self.angle) * self.orbitRadiusX
    self.lightY = cy + math.sin(self.angle) * self.orbitRadiusY

    -- detección de hover precisa
    local mx, my = love.mouse.getPosition()
    self.hover = nil
    for i, b in ipairs(self.buttons) do
        local textWidth = self.font:getWidth(b.text)
        local textHeight = self.font:getHeight()
        local bx = (w - textWidth) / 2
        local by = b.y - textHeight / 2   -- centramos la caja en el texto
        if mx >= bx and mx <= bx + textWidth and my >= by and my <= by + textHeight then
            self.hover = i
            break
        end
    end
end

function Menu:draw()
    local w, h = love.graphics.getDimensions()
    love.graphics.clear(0.05, 0.05, 0.07)

 
    love.graphics.stencil(function()
    love.graphics.circle("fill", self.lightX, self.lightY, self.lightRadius)
    end, "replace", 1)

    -- DIBUJAMOS OSCURIDAD FUERA DEL CÍRCULO (inverso al anterior)
    love.graphics.setStencilTest("equal", 0)
    love.graphics.setColor(0, 0, 0, 0.96) -- más oscuro
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setStencilTest()

    -- logo centrado
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.logo, (w - self.logoW) / 2, h * 0.15)

    -- texto
    love.graphics.setFont(self.font)
    for i, b in ipairs(self.buttons) do
        local color = (self.hover == i) and {1, 0.9, 0.3} or {1, 1, 1}
        love.graphics.setColor(color)
        local textWidth = self.font:getWidth(b.text)
        local textHeight = self.font:getHeight()
        love.graphics.print(b.text, (w - textWidth) / 2, b.y - textHeight / 2)
    end
end

function Menu:mousepressed(x, y, button)
    if button ~= 1 then return end
    local w = love.graphics.getWidth()
    for i, b in ipairs(self.buttons) do
        local textWidth = self.font:getWidth(b.text)
        local textHeight = self.font:getHeight()
        local bx = (w - textWidth) / 2
        local by = b.y - textHeight / 2
        if x >= bx and x <= bx + textWidth and y >= by and y <= by + textHeight then
            if b.action == "play" and self.onPlay then
                self.onPlay()
            elseif b.action == "quit" then
                love.event.quit()
            end
        end
    end
end

return Menu
