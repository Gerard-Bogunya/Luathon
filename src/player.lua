local Actor = Actor or require "src/actor"
local Vector = Vector or require "lib/vector"
local Player = Actor:extend()

function Player:new(_time, _repeat)    
    self.speed = 100
end

function Player:update(dt)
    
  -- marquem direcció del vector
  if love.keyboard.isDown("d") then 
  
    self.forward = Vector(1,0)
  end
  if love.keyboard.isDown("a") then 
    
    self.forward = Vector(-1,0)
  end

  -- moviment de la nau
  self.position = self.position + self.forward * self.speed * dt

end

function Player:draw()  
    local xx = self.position.x
    local ox = self.origin.x
    local yy = self.position.y
    local oy = self.origin.y
    local rr = self.rot  
    love.graphics.circle("fill", xx, yy, 3)
end

return Player
