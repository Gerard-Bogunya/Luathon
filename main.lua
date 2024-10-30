local Ball = Ball or require "src/ball"
local Paddle = Paddle or require "src/paddle"
local Score = Score or require "src/score"

actorList = {}

function love.load(arg)
  if arg[#arg] == "vsc_debug" then require("lldebugger").start() end -- Enable the debugging with vscode   ç

  local b = Ball()
  table.insert(actorList, b)
  local p = Paddle()
  table.insert(actorList, p)
  local s = Score()
  table.insert(actorList, s)
 
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