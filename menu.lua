require "library/simple-slider"
game = {}
game.width, game.height, game.flags = love.window.getMode()

if love.filesystem.getInfo( "quozul-games/destructive-dot.sav" ) then
    chunk = love.filesystem.load("quozul-games/destructive-dot.sav")
    loaded = chunk()

    -- slider = newSlider(x, y, length, value, min, max, setter, style)
    difficultySlider = newSlider(game.width / 2 - 200, 100, 200, loaded.objectsLimit, 30, 5, function() end, {width=15, orientation='horizontal', track='roundrect', knob='circle'})
    particlesSlider = newSlider(game.width / 2 - 200, 200, 200, loaded.particles, 0, 150, function() end, {width=15, orientation='horizontal', track='roundrect', knob='circle'})
end

sounds = {}
sounds.click = love.audio.newSource("data/click.ogg", "stream")

function menu()
    if not game.settings then

        -- ================================ MAIN MENU ================================ --

        if buttonHover(game.width / 2 - 100, game.height / 2 - 200, 200, 100) and click() then
            love.audio.stop(sounds.click)
            love.audio.play(sounds.click)
            game.start = true
        elseif buttonHover(game.width / 2 - 100, game.height / 2 - 50, 200, 100) and click() then
            love.audio.stop(sounds.click)
            love.audio.play(sounds.click)
            game.settings = true
        elseif buttonHover(game.width / 2 - 100, game.height / 2 + 100, 200, 100) and click() then
            love.audio.stop(sounds.click)
            love.audio.play(sounds.click)
            love.event.quit()
        end

        for e,_ in ipairs(objects.particles) do
            table.remove(objects.particles, e)
        end

        canPushTimer = 0
        canPush = false

    else
        -- ================================ SETTINGS MENU ================================ --
        if love.keyboard.isDown("escape") then
            game.settings = false
        end

        difficultySlider:update()
        if objects.limit ~= difficultySlider:getValue() then
            for e,_ in ipairs(objects.objects) do
                table.remove(objects.objects, e)
            end
            objects.count = 0
            ply.score = 0
            ply.destructionSeries = 0
            objects.limit = difficultySlider:getValue()
        end

        particlesSlider:update()
        if (minParts + maxParts) / 2 ~= particlesSlider:getValue() then
            local parts = particlesSlider:getValue()
            minParts, maxParts = parts - 5, parts + 5
        end

        if buttonHover(game.width - gameFont:getWidth("Back ←") - 10, gameFont:getHeight("Back ←"), gameFont:getWidth("Back ←"), gameFont:getHeight("Back ←")) and click() then
            love.audio.stop(sounds.click)
            love.audio.play(sounds.click)
            game.settings = false
        end
    end
end

function drawmenu()
    -- ================================ MAIN MENU ================================ --

    if not game.settings then
        love.graphics.draw(images.menu, 0, 0)
    else
        -- ================================ SETTINGS MENU ================================ --
        love.graphics.setFont( gameFont )

        love.graphics.print("Settings", game.width / 2 - gameFont:getWidth("Settings") / 2, 32)

        difficultySlider:draw("Difficulty", "Easy", "Hard")
        particlesSlider:draw("Particles", "Little", "Many")

        setColorRGB(255, 255, 255)
        love.graphics.print("Back ←", game.width - gameFont:getWidth("Back ←") - 10, gameFont:getHeight("Back ←"))
    end
end
