require "libraries/quozul-tools"
require "libraries/simple-slider"
require "libraries/button"
require "objects"

function menuUpdate()
    play:update()
    settings:update()
    quit:update()

    if play:isPressed() then
        game.menu, game.play = false, true
        restart()
    elseif settings:isPressed() then
    elseif quit:isPressed() then
        --love.event.quit()
    end
end

function menuDraw()
    setColorRGB(241, 196, 15)
    play:draw("Play")
    setColorRGB(133, 193, 233)
    settings:draw("Settings")
    setColorRGB(192, 57, 43)
    quit:draw("Quit")
end
