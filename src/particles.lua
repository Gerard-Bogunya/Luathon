local Particles = {}
Particles.__index = Particles

function Particles:new()
    local o = setmetatable({}, self)
    o.fragments = {}
    return o
end

function Particles:spawn(x, y, kind, color)
    for i = 1, 3 do
        local angle = math.random() * math.pi * 2
        local speed = 100 + math.random() * 100
        table.insert(self.fragments, {
            x = x,
            y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed - 50,
            life = 1.2,
            rotation = math.random() * math.pi * 2,
            rotSpeed = (math.random() - 0.5) * 4,
            kind = kind,
            color = { color[1], color[2], color[3], 1 },
        })
    end
end

function Particles:update(dt)
    for i = #self.fragments, 1, -1 do
        local f = self.fragments[i]
        f.x = f.x + f.vx * dt
        f.y = f.y + f.vy * dt
        f.vy = f.vy + 200 * dt -- gravedad suave
        f.rotation = f.rotation + f.rotSpeed * dt
        f.life = f.life - dt
        f.color[4] = f.life -- desvanecer
        if f.life <= 0 then
            table.remove(self.fragments, i)
        end
    end
end

function Particles:draw()
    for _, f in ipairs(self.fragments) do
        love.graphics.push()
        love.graphics.translate(f.x, f.y)
        love.graphics.rotate(f.rotation)
        love.graphics.setColor(f.color)
        if f.kind == "normal" then
            love.graphics.circle("fill", 0, 0, 6)
        elseif f.kind == "triangle" then
            love.graphics.polygon("fill", 0, -8, 6, 6, -6, 6)
        elseif f.kind == "boss" then
            love.graphics.circle("fill", 0, 0, 10)
        end
        love.graphics.pop()
    end
end

return Particles
