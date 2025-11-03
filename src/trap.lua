local Trap = {}
Trap.__index = Trap
function Trap:new(x,y)
    local o = setmetatable({}, self)
    o.x = x; o.y = y
    o.life = 999
    return o
end
function Trap:update()
    
end
setmetatable(Trap, { __call = function(cls, ...) return cls:new(...) end })
return Trap