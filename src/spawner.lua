local Actor = Actor or require "src/actor"
local Vector = Vector or require "lib/vector"
local Spawner = Actor:extend()
local Enemy = Enemy or require "src/enemy"

function Spawner:new(_time, _repeat)
  self.tActual = 0
  self.tFinal = _time or 5
  self.loop = _repeat or false
end

function Spawner:update(dt)
  self.tActual = self.tActual + dt
  if self.tActual > self.tFinal then
    self:trigger()
    if self.loop then
      self.tActual = 0
    else
      for k, v in pairs(actorList) do
        if v == self then
          table.remove(actorList, k)
          break
        end
      end
    end
  end
end

function Spawner:trigger()
  local e = Enemy()
  table.insert(actorList, e)
end

function Spawner:draw()
end

return Spawner
