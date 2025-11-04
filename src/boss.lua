local Boss = {}
Boss.__index = Boss

function Boss:new(x, y)
    local o = setmetatable({}, self)
    o.x = x
    o.y = y
    o.radius = 60   -- 4 veces más grande que un normal
    o.color = {1, 0.1, 0.1}
    o.state = "alive"
    o.hitCount = 0
    o.maxHits = 4
    o.speed = 60
    o.dir = math.random() * 2 * math.pi
    return o
end

function Boss:update(dt)
    if self.state ~= "trapped" then
        -- Movimiento lento pero errático
        local jitter = (math.random() - 0.5) * 1.5
        self.dir = self.dir + jitter * dt
        self.x = self.x + math.cos(self.dir) * self.speed * dt
        self.y = self.y + math.sin(self.dir) * self.speed * dt

        local w, h = love.graphics.getDimensions()
        if self.x < self.radius then
            self.x = self.radius
            self.dir = math.pi - self.dir
        elseif self.x > w - self.radius then
            self.x = w - self.radius
            self.dir = math.pi - self.dir
        end
        if self.y < self.radius then
            self.y = self.radius
            self.dir = -self.dir
        elseif self.y > h - self.radius then
            self.y = h - self.radius
            self.dir = -self.dir
        end
    end
end

function Boss:draw(isVisible)
    if not isVisible then return end
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("line", self.x, self.y, self.radius)
end

function Boss:containsPoint(px, py)
    local dx, dy = self.x - px, self.y - py
    return (dx * dx + dy * dy) <= (self.radius * self.radius)
end

function Boss:hit()
    if self.state == "trapped" then return end

    self.hitCount = self.hitCount + 1

    -- Efecto visual al golpearlo
    self.radius = self.radius * 0.75
    self.color = {1, 0.3 + 0.1 * self.hitCount, 0.1}

    -- Teletransporte
    local w, h = love.graphics.getDimensions()
    self.x = math.random(self.radius, w - self.radius)
    self.y = math.random(self.radius, h - self.radius)

    if self.hitCount >= self.maxHits then
        -- se convierte en un monstruo normal capturable
        self.state = "weakened"
        self.radius = 15
        self.color = {0.8, 0.2, 0.2}
        self.speed = 100
    end
end

return Boss
