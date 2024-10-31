local Actor = Actor or require "src/actor"
local Vector = Vector or require "lib/vector"
local Enemy = Actor:extend()

math.randomseed(os.time())

function Enemy:new(_time, _repeat)  
    self.color = nill
    self.blueImage = love.graphics.newImage("src/textures/e_blue.png")
    self.redImage = love.graphics.newImage("src/textures/e_red.png")
    self.yellowImage = love.graphics.newImage("src/textures/e_yellow.png")
    self.greenImage = love.graphics.newImage("src/textures/e_green.png")  

    
    Enemy.super.new(self, self.image, 0, 0, 0)
    self:SetColor()       
    self:RandomOrigin()   
    self.forward = Vector(1,0)
    self.speed = 100
    self:RandomAngle()

    
    
    
end

function Enemy:update(dt)   

    
    self:Movement(dt)

end

function Enemy:draw()
    local xx = self.position.x
    local ox = self.origin.x
    local yy = self.position.y
    local oy = self.origin.y
    local rr = self.rot  
    love.graphics.draw(self.image, xx, yy, rr, 1, 1, ox, oy)   
end

function Enemy:SetColor()
    local color = math.random(1,4)

if color == 1 then 
    self.image = self.blueImage
    self.color = "blue" 
elseif color == 2 then  
    self.image = self.greenImage
    self.color = "green"
elseif color == 3 then  
    self.image = self.redImage
    self.color = "red"
elseif color == 4 then  
    self.image = self.yellowImage
    self.color = "yellow"
end
end

function Enemy:RandomOrigin()
    w, h = love.graphics.getDimensions()
    self.position.x = math.random(50, w-50)
    self.position.y = math.random(50, h-50)
    print (self.position.x, self.position.y)
    
end
function Enemy:RandomAngle()
    self.rot = math.random(0,360)      
end

function Enemy:Movement(dt)
    local w, h = love.graphics.getDimensions()   
    
    self.position.x = self.position.x + math.cos(self.rot) * self.speed * dt
    self.position.y = self.position.y + math.sin(self.rot) * self.speed * dt
    
    if(self.position.x - (self.width/2)  < 0) then
        self.rot = math.pi - self.rot
        self.speed = self.speed + 50
       
    end
    if(self.position.x + (self.width/2)  > w) then
        self.rot = math.pi - self.rot
        self.speed = self.speed + 50
        
    end   
    
    if(self.position.y - (self.height/2) < 0) then         
        self.rot = self.rot * (-1)
        self.speed = self.speed + 50
        
    end
    
    if(self.position.y + (self.height/2) > h) then      
        self.rot = self.rot * (-1)
        self.speed = self.speed + 50
        
    end

end

return Enemy
