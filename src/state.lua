-- src/state.lua
-- Este archivo centraliza todos los estados del juego
-- y permite cambiarlos fácilmente desde cualquier parte.

local State = {
    current = "menu", -- Estado inicial
    previous = nil
}

State.list = {
    MENU = "menu",
    GAME = "game",
    UPGRADE = "upgrade",
    TRANSITION = "transition",
    GAMEOVER = "gameover"
}

-- Cambia el estado actual
function State:set(newState)
    self.previous = self.current
    self.current = newState
end

-- Obtiene el estado actual
function State:get()
    return self.current
end

-- Comprueba si estamos en un estado concreto
function State:is(stateName)
    return self.current == stateName
end

return State
