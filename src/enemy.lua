local Actor = Actor or require "src/actor"
local Vector = Vector or require "lib/vector"
local Enemy = Actor:extend()

math.randomseed(os.time())

function Enemy:new(_time, _repeat)  

    self.blueImage = love.graphics.newImage("src/textures/e_blue.png")
    self.redImage = love.graphics.newImage("src/textures/e_red.png")
    self.yellowImage = love.graphics.newImage("src/textures/e_yellow.png")
    self.greenImage = love.graphics.newImage("src/textures/e_green.png")


    Enemy.super.new(self, self.image, 0, 0, 0)
    self:SetColor()       
    self:RandomOrigin()   
    
    
end

function Enemy:update(dt)
end

function Enemy:trigger()
  
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

if color == 1 then self.image = self.blueImage
elseif color == 2 then  self.image = self.greenImage
elseif color == 3 then  self.image = self.redImage
elseif color == 4 then  self.image = self.yellowImage
end

end

function Enemy:RandomOrigin()
    w, h = love.graphics.getDimensions()
    self.position.x = math.random(50, w-50)
    self.position.y = math.random(50, h-50)
    print (self.position.x, self.position.y)
    
end

return Enemy
