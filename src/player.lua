local Actor = Actor or require "src/actor"
local Vector = Vector or require "lib/vector"
local Player = Actor:extend()

function Player:new()   
  Player.super.new(self, "src/textures/p_blue_small.png", 180, 540, 0)
    self.speed = 250    
    self.color = "blue"
end

function Player:update(dt)
    
   -- Movimiento en el eje Y (arriba y abajo)
   if love.keyboard.isDown("up") then
    self.position.y = self.position.y - self.speed * dt
elseif love.keyboard.isDown("down") then
  self.position.y = self.position.y + self.speed * dt
end

-- Movimiento en el eje X (izquierda y derecha)
if love.keyboard.isDown("left") then
  self.position.x = self.position.x - self.speed * dt
elseif love.keyboard.isDown("right") then
  self.position.x = self.position.x + self.speed * dt
self.forward = Vector(1,-1)    
end

if love.keyboard.isDown("space") then
 self:ChangeColor(self.color)
end

print (self.color)

end

function Player:draw()  
    local xx = self.position.x
    local ox = self.origin.x
    local yy = self.position.y
    local oy = self.origin.y
    local rr = self.rot  
    love.graphics.draw(self.image, xx, yy, rr, 1, 1, ox, oy)
    
end


function Player:ChangeColor(actualColor)

  if actualColor == "blue" then self.color = "red"
  elseif actualColor == "red" then self.color = "yellow"
  elseif actualColor == "yellow" then self.color = "green"
  elseif actualColor == "green" then self.color = "blue"
  end

end



return Player
