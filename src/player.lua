local Actor = Actor or require "src/actor"
local Vector = Vector or require "lib/vector"
local Player = Actor:extend()
local Enemy = Enemy or require "src/enemy"



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
  self.position.x = w/2
  self.position.y = h/2

  self.points = 0

  self.lifes = 3
  

end

function Player:update(dt)
    
  self:Movement(dt)
  self:Boundaries()
  self:SpacePressed()

local removePlayer = false

for k, v in ipairs (actorList) do
  if v:is(Enemy)then 
    local d = self:checkCollision(v)
    if d == true  then        
      if v.color == self.color then
        self.points = self.points + 1        
     table.remove(actorList, k)
      elseif v.color ~= self.color then
        if self.lifes <= 1 then 
          self.lifes = 0
          print ("GAMEOVER") -- Ir a pantalla de game over
        else      
        self.lifes = self.lifes - 1
        table.remove(actorList, k)
        end
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

function Player:Boundaries()
  local w, h = love.graphics.getDimensions()
if (self.position.x - (self.width/2) )< 0 or self.position.x + (self.width/2) > w then print("GAMEOVER")
end
if (self.position.y - (self.height/2) ) < 0 or self.position.y + (self.height/2)  > h then print("GAMEOVER")
end
end

function Player:Movement(dt)
     
  if love.keyboard.isDown("w") then
    self.position.y = self.position.y - self.speed * dt
elseif love.keyboard.isDown("s") then
  self.position.y = self.position.y + self.speed * dt
end

if love.keyboard.isDown("a") then
  self.position.x = self.position.x - self.speed * dt
elseif love.keyboard.isDown("d") then
  self.position.x = self.position.x + self.speed * dt
self.forward = Vector(1,-1)    
end
end

function Player:SpacePressed()
  if love.keyboard.isDown("space") then
    if not self.spacePressed then
       self:SetColor(self.color)
       self.spacePressed = true  -- Evita cambios adicionales hasta que se suelte "space"
    end
  else
    self.spacePressed = false  -- Permite cambiar de color nuevamente cuando se suelte "space"
  end
end

return Player
