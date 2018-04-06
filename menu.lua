require "libraries/quozul-tools"
require "libraries/simple-slider"
require "libraries/simple-button"
require "objects"

function menuUpdate()
    play:update()
    settings:update()
    quit:update()

    if play:isPressed() then
        game.menu, game.play, game.pause = false, true, false
        restart()
    elseif settings:isPressed() then
        game.menu, game.settings = false, true
    elseif quit:isPressed() then
        love.event.quit()
    end
end

function menuDraw()
    love.graphics.setFont(Font24)

    setColorRGB(241, 196, 15)
    play:draw("Play")
    setColorRGB(133, 193, 233)
    settings:draw("Settings")
    setColorRGB(192, 57, 43)
    quit:draw("Quit")
end

function settingsUpdate()
    difficultySlider:update()
    particlesSlider:update()

    fullscreen:update()
    back:update()

    if game.maxParticles ~= particlesSlider:getValue() then
        game.maxParticles = particlesSlider:getValue()
    elseif game.objectsLimit ~= difficultySlider:getValue() then
        game.objectsLimit = difficultySlider:getValue()
    end

    if fullscreen:isChecked() then
        love.window.setFullscreen(true)
    else
        love.window.setFullscreen(false)
    end

    if back:isPressed() then
        game.menu = true
        game.settings = false
    end
end

function settingsDraw()
    love.graphics.setFont(Font12)

    love.graphics.print("Settings", game.width / 2 - Font12:getWidth("Settings") / 2, 10)

    difficultySlider:draw("Difficulty", "Easy", "Hard")
    particlesSlider:draw("Particles", "None", "Lot")

    fullscreen:draw("Fullscreen")

    back:draw("← Back")
end
