local Actor = Actor or require "src/actor"
local Vector = Vector or require "lib/vector"
local Hud = Actor:extend()
local Player = Player or require "src/player"

function Hud:new()
  fuente =love.graphics.newFont("src/Super_Shiny.ttf", 24)
  love.graphics.setFont(fuente)
  
  self.position = Vector.new(100, 300)
  self.puntuation = 0
  self.lifes = 3
  end
  
  function Hud:update(dt)

    for k, v in ipairs (actorList) do
        if v:is(Player)then 
          self.puntuation = v.points    
          self.lifes = v.lifes   
          end
        end      

  end

  
  
  function Hud:draw()
    love.graphics.print("Points: " .. self.puntuation, 100, 30)     
    love.graphics.print("Lifes: " .. self.lifes, 500, 30)    
    
  end
  
  return Hud
  