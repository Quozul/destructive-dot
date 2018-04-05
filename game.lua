require "objects"
require "libraries/simple-button"

function gameUpdate()
    removeObject()

    if playerSpeed(0.001) then ply.xs, ply.ys = 0, 0 end -- Sets the speed to 0

    -- Player movements
    ply.x = ply.x + ply.xs
    ply.y = ply.y + ply.ys

    ply.xs = ply.xs / 1.3
    ply.ys = ply.ys / 1.3

    -- Collision with border of the window
    if ply.x + game.playerRadius >= game.width - game.xBorder then
        ply.xs = -ply.xs
        ply.x = game.width - game.xBorder - game.playerRadius
        wallHitSound()
    elseif ply.x - game.playerRadius <= game.xBorder then
        ply.xs = -ply.xs
        ply.x = game.xBorder + game.playerRadius
        wallHitSound()
    end

    if ply.y + game.playerRadius >= game.height - game.yBorder then
        ply.ys = -ply.ys
        ply.y = game.height - game.yBorder - game.playerRadius
        wallHitSound()
    elseif ply.y - game.playerRadius <= game.yBorder then
        ply.ys = -ply.ys
        ply.y = game.yBorder + game.playerRadius
        wallHitSound()
    end

    -- If there is not enought objects                         then create a new object
    if game.objectsCount < game.objectsLimit and playerSpeed(0.01) then addObject() end

    updateParticles()

    if not objectInReach() and playerSpeed(0.001) and ply.shots ~= 0 then game.over = true else game.over = false end
    if not objectInReach() and ply.shots == 0 then clearObjects() end

    if buttonHover(game.width - 32, 6, 22, 21) and click.isNew() then game.menu = true end
end

function restart()
    clearObjects()
    game.over = false
    ply.shots = 0
    ply.score = 0
    game.objectsCount = 0
    ply.x, ply.y = game.width / 2, game.height / 2
end

function wallHitSound()
    love.audio.stop(sounds.hitWall)
    love.audio.play(sounds.hitWall)
end

function playerSpeed(v) if math.abs(ply.xs + ply.ys) <= v then return true end end

function drawGame()
    love.graphics.setFont(Font12)
    setColorRGB(44, 62, 80)
    love.graphics.rectangle("fill", game.xBorder, game.yBorder, game.width - game.xBorder * 2, game.height - game.yBorder * 2)

    setColorRGB(255, 255, 255)
    love.graphics.circle("fill", ply.x, ply.y, game.playerRadius)

    love.graphics.print("Score: " ..ply.score, 10, 10)

    if not game.over then love.graphics.draw(images.pause, game.width - 32, 6) end -- Pause icon
end

function gameOver()
    retry:update()
    menu:update()

    if retry:isPressed() then restart() end
    if menu:isPressed() then
        game.play = false
        game.menu = true
        restart()
    end
end

function drawGameOver()
    love.graphics.setFont(Font24)
    setColorRGB(0, 0, 0)

    love.graphics.setFont(Font24)
    love.graphics.print("You lose.", game.width / 2 - Font24:getWidth("You lose.") / 2, game.height / 2 - Font24:getHeight("You lose.") / 2)

    setColorRGB(192, 57, 43)
    retry:draw("Retry")
    setColorRGB(241, 196, 15)
    menu:draw("Menu")
end
