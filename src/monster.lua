local Monster = {}
Monster.__index = Monster

function Monster:new(x, y, kind)
    local o = setmetatable({}, self)
    o.x = x or 0
    o.y = y or 0
    o.dir = math.random() * 2 * math.pi
    o.state = "alive"
    o.kind = kind or "normal"

    if o.kind == "normal" then
        o.speed = 80 + math.random() * 40
        o.radius = 15
        o.color = {0.8, 0.2, 0.2}
        o.clicksToTrap = 1
    elseif o.kind == "triangle" then
        o.speed = 120 + math.random() * 40
        o.radius = 10
        o.color = {1, 0.9, 0.2}
        o.clicksToTrap = 2
    end

    o.clicksDone = 0
    return o
end

function Monster:update(dt)
    if self.state ~= "trapped" then
        local jitter = (math.random() - 0.5) * 2
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

function Monster:draw(isVisible)
    if not isVisible then return end
    if self.state == "trapped" then
        love.graphics.setColor(0.6, 0.6, 1)
        love.graphics.rectangle("fill", self.x - 14, self.y - 14, 28, 28)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", self.x - 14, self.y - 14, 28, 28)
        return
    end

    love.graphics.setColor(self.color)
    if self.kind == "normal" then
        love.graphics.circle("fill", self.x, self.y, self.radius)
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("line", self.x, self.y, self.radius)
    elseif self.kind == "triangle" then
        love.graphics.push()
        love.graphics.translate(self.x, self.y)
        love.graphics.rotate(self.dir + math.pi / 2)
        local size = self.radius * 2
        love.graphics.polygon("fill", 0, -size, size * 0.8, size, -size * 0.8, size)
        love.graphics.setColor(0, 0, 0)
        love.graphics.polygon("line", 0, -size, size * 0.8, size, -size * 0.8, size)
        love.graphics.pop()
    end
end

function Monster:containsPoint(px, py)
    local dx, dy = self.x - px, self.y - py
    local hitboxRadius = self.radius
    if self.kind == "triangle" then
        hitboxRadius = hitboxRadius * 1.6
    end
    return (dx * dx + dy * dy) <= (hitboxRadius * hitboxRadius)
end

function Monster:trap()
    if self.state == "trapped" then return end

    if self.type == "triangle" then
        if not self.hitOnce then
            self.hitOnce = true
            self.speed = self.speed * 2
            self.color = {1, 0.5, 0.1} -- color naranja cuando enfurece
        else
            self.state = "trapped"
            if self.onTrapped then
                self.onTrapped(self.x, self.y)
            end
        end
    else
        self.state = "trapped"
        if self.onTrapped then
            self.onTrapped(self.x, self.y)
        end
    end
end


setmetatable(Monster, { __call = function(cls, ...) return cls:new(...) end })
return Monster
