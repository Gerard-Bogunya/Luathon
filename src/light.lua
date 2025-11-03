-- src/light.lua
local Light = {}
Light.__index = Light

function Light:new()
    local o = setmetatable({}, self)
    o.radius = 80
    o.darkness = 0.85
    o.pulse = 0
    o.x, o.y = 0, 0
    return o
end

function Light:update(dt)
    self.x, self.y = love.mouse.getPosition()
    self.pulse = self.pulse + dt * 2
end

function Light:draw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    -- Guardar estado gráfico
    love.graphics.push("all")

    -- Crear un "stencil" (máscara circular)
    love.graphics.stencil(function()
        local pulse = math.sin(self.pulse) * 5
        local radius = self.radius + pulse
        love.graphics.circle("fill", self.x, self.y, radius)
    end, "replace", 1)

    -- Usar el stencil para oscurecer solo fuera del círculo
    love.graphics.setStencilTest("less", 1)
    love.graphics.setColor(0, 0, 0, self.darkness)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setStencilTest()

    -- Restaurar estado
    love.graphics.pop()
end

setmetatable(Light, { __call = function(cls, ...) return cls:new(...) end })
return Light
