local Vector = Vector or require "lib/vector"
local Actor = Actor or require "src/actor"
local Spawner = Spawner or require "src/spawner"
local Player = Player or require "src/player"
local Enemy = Enemy or require "src/enemy"
local Hud = Hud or require "src/hud"

actorList = {}

function love.load() 
  local p = Player()
  table.insert(actorList,p )
  local s = Spawner(2, true)
  table.insert(actorList, s)
  local hud = Hud()
  table.insert(actorList, hud)
end

function love.update(dt)
  for _, v in ipairs(actorList) do
    v:update(dt)
  end
end

function love.draw()
  for _, v in ipairs(actorList) do
    v:draw()
  end
end