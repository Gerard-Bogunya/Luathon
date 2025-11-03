local Monster = {}
Monster.__index = Monster

function Monster:new(x, y)
    local o = setmetatable({}, self)
    o.x = x or 0
    o.y = y or 0
    o.speed = 40 + math.random()*40
    o.dir = math.random() * 2 * math.pi
    o.state = "hidden" -- hidden, visible, trapped
    o.radius = 12
    o.color = {0.8, 0.2, 0.2}
    return o
end

function Monster:update(dt)
    if self.state ~= "trapped" then
        -- movimiento errático
        local jitter = (math.random()-0.5) * 2
        self.dir = self.dir + jitter * dt
        self.x = self.x + math.cos(self.dir) * self.speed * dt
        self.y = self.y + math.sin(self.dir) * self.speed * dt
        -- límites de pantalla
        local w,h = love.graphics.getWidth(), love.graphics.getHeight()
        if self.x < 0 then self.x = 0; self.dir = math.pi - self.dir end
        if self.x > w then self.x = w; self.dir = math.pi - self.dir end
        if self.y < 0 then self.y = 0; self.dir = -self.dir end
        if self.y > h then self.y = h; self.dir = -self.dir end
    end
end

function Monster:draw(isVisible)
    if self.state == "trapped" then
        -- jaula: dibujar un cuadrado con líneas
        love.graphics.setColor(0.6,0.6,1)
        love.graphics.rectangle("fill", self.x - 14, self.y - 14, 28, 28)
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("line", self.x - 14, self.y - 14, 28, 28)
    else
        if isVisible then
            love.graphics.setColor(self.color)
            love.graphics.circle("fill", self.x, self.y, self.radius)
            love.graphics.setColor(0,0,0)
            love.graphics.circle("line", self.x, self.y, self.radius)
        else
            -- no dibujar si está oculto
        end
    end
end

function Monster:containsPoint(px, py)
    local dx = self.x - px
    local dy = self.y - py
    return (dx*dx + dy*dy) <= (self.radius * self.radius)
end

function Monster:trap()
    if self.state ~= "trapped" then
        self.state = "trapped"
        self.trappedTimer = 0
    end
end

setmetatable(Monster, { __call = function(cls, ...) return cls:new(...) end })
return Monster