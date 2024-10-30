  local Object = Object or require "lib/object"
  local Ball = Object:extend()
  local Score = Score or require "src/score"
  local Paddle = Paddle or require "src/paddle"

  local cpuX, cpuY, playerX, playerY, up, down
 
  local w, h

  local playerSum, cpuSum

  

  function Ball:new(dt)

      w, h = love.graphics.getDimensions()

      self.ballX = w/2
      ballY = h/2
      self.ballSpeed = 200
      self.ballAngle = 150 

  end

  function Ball:update(dt)

    self.ballX = self.ballX + math.cos(self.ballAngle) * self.ballSpeed * dt
    ballY = ballY + math.sin(self.ballAngle) * self.ballSpeed * dt
    
    for k, v in ipairs(actorList) do
      if v:is(Paddle) then
          cpuX = v.cpuX
          cpuY = v.cpuY
          playerX = v.playerX
          playerY = v.playerY           
          
          break            
      end
  end
  
    deltaX = self.ballX - math.max(cpuX, math.min(self.ballX, cpuX + 10))
    deltaY = ballY - math.max(cpuY, math.min(ballY, cpuY + 50))
      if (deltaX * deltaX + deltaY * deltaY) < (10 * 10) then
        self.ballAngle = math.pi - self.ballAngle
        self.ballSpeed = self.ballSpeed + 30
      
      end
    deltaX = self.ballX - math.max(playerX, math.min(self.ballX, playerX + 10))
    deltaY = ballY - math.max(playerY, math.min(ballY, playerY + 50))
      if (deltaX * deltaX + deltaY * deltaY) < (10 * 10) then
        self.ballAngle = math.pi - self.ballAngle
        self.ballSpeed = self.ballSpeed + 30
      end  
    
    if(ballY < 0) then
      self.ballAngle = self.ballAngle * (-1)
      self.ballSpeed = self.ballSpeed + 30
    end
    if(ballY > 600) then
      self.ballAngle = self.ballAngle * (-1)
      self.ballSpeed = self.ballSpeed + 30
    end

    
    
    if(self.ballX < 0) then
      for k, v in ipairs(actorList) do
        if v:is(Score) then
                v:CpuSum()               
            break            
        end
    end
      self.ballX = w/2
      ballY = h/2
      self.ballSpeed = 150 
    end

    
    if(self.ballX > w) then
      for k, v in ipairs(actorList) do
        if v:is(Score) then
                v:PlayerSum()               
            break            
        end
    end
      self.ballX = w/2
      ballY = h/2
      self.ballSpeed = 150
    end

    


  end

  function Ball:draw()
      love.graphics.circle("fill", self.ballX, ballY, 10)
  end

  return Ball