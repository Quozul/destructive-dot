

function menu()
    if not game.settings then

        -- ================================ MAIN MENU ================================ --

        if buttonHover(game.width / 2 - 100, game.height / 2 - 200, 200, 100) and click() then
            game.start = true
            canPushTimer = 0
            canPush = false
        elseif buttonHover(game.width / 2 - 100, game.height / 2 - 50, 200, 100) and click() then
            game.settings = true
        elseif buttonHover(game.width / 2 - 100, game.height / 2 + 100, 200, 100) and click() then
            love.event.quit()
        end

    else
        -- ================================ SETTINGS MENU ================================ --
        if love.keyboard.isDown("escape") then
            game.settings = false
        end

        slider.update()

    end
end

function drawmenu()
    -- ================================ MAIN MENU ================================ --

    if not game.settings then
        love.graphics.setFont( menuFont )
        love.graphics.setColor(241, 196, 15)
        love.graphics.rectangle("fill", game.width / 2 - 100, game.height / 2 - 200, 200, 100)

        love.graphics.setColor(52, 152, 219)
        love.graphics.rectangle("fill", game.width / 2 - 100, game.height / 2 - 50, 200, 100)

        love.graphics.setColor(192, 57, 43)
        love.graphics.rectangle("fill", game.width / 2 - 100, game.height / 2 + 100, 200, 100)

        love.graphics.setColor(0,0,0)
        love.graphics.print("Play", game.width / 2 - 86, game.height / 2 - 200)
        love.graphics.print("Settings", game.width / 2 - 100, game.height / 2 - 50)
        love.graphics.print("Quit", game.width / 2 - 86, game.height / 2 + 100)
    else
        -- ================================ SETTINGS MENU ================================ --
        love.graphics.setFont( gameFont )

        love.graphics.print("Settings", game.width / 2 - 100, 32)

        slider.draw()
    end
end
