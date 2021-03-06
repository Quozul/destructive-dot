require "libraries/quozul-tools"
require "libraries/simple-slider"
require "libraries/simple-button"
require "objects"

function scalingProblemsUpdate()
    no:update()
    yes:update()

    if no:isPressed() then
        option.scale = option.scale + 1
        love.event.quit("restart")
    elseif yes:isPressed() then
        option.goodScale = true
        love.event.quit("restart")
    end
end

function scalingProblemsDraw()
    love.graphics.setFont(Font24)

    local msg = "Is the scaling correct?"
    love.graphics.print(msg, game.width / 2 - Font24:getWidth(msg) / 2, game.height / 2 - Font24:getHeight(msg) / 2)

    setColorRGB(192, 57, 43)
    no:draw("No")
    setColorRGB(241, 196, 15)
    yes:draw("Yes")
end

function menuUpdate()
    clearParticles()

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

    if game.currentOS ~= "smartphone" then fullscreen:update() end
    lessParticles:update()
    infiniteParticles:update()
    showFPS:update()
    back:update()
    music:update()

    if option.maxParticles ~= particlesSlider:getValue() then
        option.maxParticles = particlesSlider:getValue()
    elseif option.objectsLimit ~= difficultySlider:getValue() then
        option.objectsLimit = difficultySlider:getValue()
    end

    if fullscreen:asChanged() and game.currentOS ~= "smartphone" then option.fullscreen = not option.fullscreen end

    if lessParticles:asChanged() then
        option.lessParticles = not option.lessParticles
        if lessParticles:isChecked() then
            option.infiniteParticles = false
            infiniteParticles:checkValue(option.infiniteParticles)
        end
    end

    if infiniteParticles:asChanged() then
        option.infiniteParticles = not option.infiniteParticles
        if infiniteParticles:isChecked() then
            option.lessParticles = false
            lessParticles:checkValue(option.lessParticles)
        end
    end

    if showFPS:asChanged() then option.showFPS = not option.showFPS end

    if music:asChanged() then option.playMusic = not option.playMusic; love.audio.stop() end

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

    lessParticles:draw("Less particles", "right")
    infiniteParticles:draw("Infinite particles life", "right")
    if game.currentOS ~= "smartphone" then fullscreen:draw("Fullscreen (need restart)", "left") end
    showFPS:draw("Show FPS", "left")
    music:draw("Musics", "left")

    back:draw("← Back")
end
