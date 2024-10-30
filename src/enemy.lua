local Actor = Actor or require "src/actor"
local Vector = Vector or require "lib/vector"
local Enemy = Actor:extend()

function Enemy:new(_time, _repeat)
end

function Enemy:update(dt)
end

function Enemy:trigger()
  
end

function Enemy:draw()
end

return Enemy
