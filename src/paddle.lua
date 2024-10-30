local Object = Object or require "lib/object"
local Paddle = Object:extend()



function Paddle:new(dt)
  self.playerX = 50
  self.playerY = 140
  self.cpuX = 750
  self.cpuY = 70

  self.paddleSpeed = 250
  self.cpuSpeed = 150

end

function Paddle:update(dt)

    if (love.keyboard.isDown("down")) then 
      self.playerY = self.playerY + self.paddleSpeed * dt
      
    end
    
    if (love.keyboard.isDown("up")) then 
        self.playerY = self.playerY - self.paddleSpeed * dt
        
    end  

    if (ballY > self.cpuY) then 
      self.cpuY =  self.cpuY + self.cpuSpeed * dt
    else  self.cpuY =  self.cpuY - self.cpuSpeed * dt
    end
    
     

end

function Paddle:draw()
  love.graphics.rectangle("fill", self.playerX, self.playerY, 10,50)
  love.graphics.rectangle("fill", self.cpuX, self.cpuY, 10,50)
  
end

function Paddle:up(dt)
  
  self.cpuY =  self.cpuY - self.cpuSpeed * dt

end

function Paddle:down(dt)
  self.cpuY =  self.cpuY + self.cpuSpeed * dt
  
  
end

return Paddle