local Object = Object or require "lib/object"
local Score = Object:extend()

local w, h
local midGame
local gol1
local gol2

function Score:new(dt)

  w, h = love.graphics.getDimensions()

self.playerPoints = 0
self.cpuPoints = 0

    fuente =love.graphics.newFont("src/pong.ttf", 24)
    love.graphics.setFont(fuente)    
    midGame = love.graphics.newImage"src/mid_game.png"
    gol1 = love.graphics.newImage"src/gol_1.png"
    gol2 = love.graphics.newImage"src/gol_2.png"
end

function Score:update(dt)
end

function Score:draw()
  love.graphics.print("Player: " .. self.playerPoints, 150, 50)  
  love.graphics.print("CPU: " .. self.cpuPoints, 550, 50) 
  love.graphics.draw(midGame, 400)
  love.graphics.draw(gol1)
  love.graphics.draw(gol2, 600)
end

function Score:PlayerSum()
  self.playerPoints = self.playerPoints + 1
end
function Score:CpuSum()
  self.cpuPoints = self.cpuPoints + 1
end

return Score