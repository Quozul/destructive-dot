require "libraries/quozul-tools"
require "libraries/simple-button"
require "objects"

function menuUpdate()
    play:update()
    quit:update()

    if play:isPressed() then
        game.menu, game.play = false, true
        restart()
    elseif quit:isPressed() then
        love.event.quit()
    end
end

function menuDraw()
    love.graphics.setFont(Font24)

    setColorRGB(241, 196, 15)
    play:draw("Play")
    setColorRGB(192, 57, 43)
    quit:draw("Quit")
end
