local Actor = Actor or require "src/actor"
local Vector = Vector or require "lib/vector"
local Player = Actor:extend()
local Enemy = Enemy or require "src/enemy"

puntuation = 0

function Player:new()   
  local w, h = love.graphics.getDimensions()
  Player.super.new(self, "src/textures/p_blue_small.png", w/2, h/2, 0)
  self.speed = 250    
  self.color = "blue"
  self.blueImage = love.graphics.newImage("src/textures/p_blue_small.png")
  self.redImage = love.graphics.newImage("src/textures/p_red_small.png")
  self.yellowImage = love.graphics.newImage("src/textures/p_yellow_small.png")
  self.greenImage = love.graphics.newImage("src/textures/p_green_small.png")
  self.spacePressed = false
  

end

function Player:update(dt)
    
   -- Movimiento en el eje Y (arriba y abajo)
   if love.keyboard.isDown("w") then
    self.position.y = self.position.y - self.speed * dt
elseif love.keyboard.isDown("s") then
  self.position.y = self.position.y + self.speed * dt
end

-- Movimiento en el eje X (izquierda y derecha)
if love.keyboard.isDown("a") then
  self.position.x = self.position.x - self.speed * dt
elseif love.keyboard.isDown("d") then
  self.position.x = self.position.x + self.speed * dt
self.forward = Vector(1,-1)    
end

if love.keyboard.isDown("space") then
  if not self.spacePressed then
     self:SetColor(self.color)
     self.spacePressed = true  -- Evita cambios adicionales hasta que se suelte "space"
  end
else
  self.spacePressed = false  -- Permite cambiar de color nuevamente cuando se suelte "space"
end

local removePlayer = false

for k, v in ipairs (actorList) do
  if v:is(Enemy)then 
    local d = self:checkCollision(v)
    if d == true  then        
      if v.color == self.color then
     table.remove(actorList, k)
      elseif v.color ~= self.color then
      -- Ir a pantalla de game over
      print ("GAME OVER")

    
    end
    end
  end
end


end

function Player:draw()  
    local xx = self.position.x
    local ox = self.origin.x
    local yy = self.position.y
    local oy = self.origin.y
    local rr = self.rot  
    love.graphics.draw(self.image, xx, yy, rr, 1, 1, ox, oy)    
end


function Player:SetColor(actualColor)

  if actualColor == "blue" then self.color = "red"
  elseif actualColor == "red" then self.color = "yellow"
  elseif actualColor == "yellow" then self.color = "green"
  elseif actualColor == "green" then self.color = "blue"
  end 
  self:ChangeColor(self.color)
end

function Player:ChangeColor()
  if self.color == "blue" then self.image = self.blueImage
  elseif self.color == "red" then self.image = self.redImage
  elseif self.color == "yellow" then self.image = self.yellowImage
  elseif self.color == "green" then self.image = self.greenImage
  end 
end



return Player
