local Vector = Vector or require "lib/vector"
local Actor = Actor or require "src/actor"
local Spawner = Spawner or require "src/spawner"
local Player = Player or require "src/player"
local Enemy = Enemy or require "src/enemy"
local Hud = Hud or require "src/hud"

actorList = {}
local gameState = "MainMenu"

function love.load() 
  w1, h1 = love.graphics.getDimensions()
  menu = love.graphics.newImage("src/textures/main_menu.png")
  p = Player()
  table.insert(actorList,p )
  s = Spawner(2, true)
  table.insert(actorList, s)
  hud = Hud()
  table.insert(actorList, hud)
end

function love.update(dt)

if gameState == "Play" then
  for _, v in ipairs(actorList) do
    v:update(dt)
  end
end
if p.lifes == 0 then 
  gameState = "GameOver"
  end
end


function love.draw()
if gameState == "MainMenu" then 
  love.graphics.draw(menu, w1/3.5, h1/5, 0, 2, 2)
  --love.graphics.setFont(love.graphics.newFont("src/Super_Shiny.ttf", 200))
  --love.graphics.printf("GAME", 0, h1/2-250, w1, "center")
  --love.graphics.setFont(love.graphics.newFont("src/Super_Shiny.ttf", 50))
  --love.graphics.printf("Pulsa 1. Jugar", 0, h1/2 - 50, w1, "center") --Opción de jugar
  --love.graphics.printf("Pulsa 2. Salir", 0, h1/2 + 50, w1, "center")
  --love.graphics.setFont(love.graphics.newFont("src/Super_Shiny.ttf", 24))

elseif gameState == "Play" then
  for _, v in ipairs(actorList) do
    v:draw()
  end

elseif gameState == "GameOver" then 
  love.graphics.setFont(love.graphics.newFont("src/Super_Shiny.ttf", 200))
  love.graphics.setColor(1, 0, 0)
  love.graphics.printf("Game Over", 0, h1/2 - 200, w1, "center")
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(love.graphics.newFont("src/Super_Shiny.ttf", 24))
end
end

function love.keypressed(key)
  if gameState == "MainMenu" then 

    if key == "space" then 
      gameState = "Play"

    elseif key == "escape" then 
      love.event.quit()
    end

  end
end