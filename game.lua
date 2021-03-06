require "objects"
require "libraries/simple-button"

PotentialGravityEnergy = 0

function gameUpdate()
    updateObjects()
    updateParticles()

    if playerSpeed(0.001) then ply.xs, ply.ys = 0, 0 end -- Sets the speed to 0

    -- Player movements
    ply.x = ply.x + ply.xs
    ply.y = ply.y + ply.ys

    PotentialGravityEnergy = (ply.y - (game.height - game.yBorder))

    if option.gravity and ply.y <= game.height and math.abs(PotentialGravityEnergy) >= game.playerRadius + 1 then ply.ys = ply.ys + 0.1 end
    if option.gravity and ply.ys < 0 then ply.ys = 0 end
    if option.gravity and math.abs(PotentialGravityEnergy) <= game.playerRadius + 1 then ply.xs = ply.xs / 2 end

    if not game.gravity then
        ply.ys = ply.ys / 1.3
        ply.xs = ply.xs / 1.3
    end

    -- Collision with border of the window
    if ply.x + game.playerRadius >= game.width - game.xBorder then
        ply.xs = -ply.xs
        ply.x = game.width - game.xBorder - game.playerRadius
    elseif ply.x - game.playerRadius <= game.xBorder then
        ply.xs = -ply.xs
        ply.x = game.xBorder + game.playerRadius
    end

    if ply.y + game.playerRadius >= game.height - game.yBorder then
        ply.ys = -ply.ys
        ply.y = game.height - game.yBorder - game.playerRadius
    elseif ply.y - game.playerRadius <= game.yBorder and not option.gravity then
        ply.ys = -ply.ys
        ply.y = game.yBorder + game.playerRadius
    end

    if ply.x + game.playerRadius >= game.width - game.xBorder or ply.x - game.playerRadius <= game.xBorder or ply.y + game.playerRadius >= game.height - game.yBorder or ply.y - game.playerRadius <= game.yBorder and not option.gravity then
        wallHitSound()

        if not option.lessParticles then
            for n=option.maxParticles / 2, option.maxParticles do
                addParticles(ply.x, ply.y, "white")
            end
        end
        if option.gravity then
            ply.xs = ply.xs / 2
        end
    end

    -- If there is not enought objects                         then create a new object
    if game.objectsCount < option.objectsLimit and playerSpeed(0.1) then addObject() end

    if not objectInReach() and playerSpeed(0.001) and ply.shots ~= 0 then game.over = true else game.over = false end
    if not objectInReach() and ply.shots == 0 then clearObjects() end

    if buttonHover(game.width - 32, 6, 22, 21) and click.isNew() then game.menu = true end

    if playerSpeed(0.1) then
        ply.destructionSeries = 1
        ply.newScore = 0
    end
end

function restart()
    clearObjects()
    clearParticles()
    game.over = false
    ply.shots = 0
    ply.score = 0
    game.objectsCount = 0
    ply.x, ply.y = game.width / 2, game.height / 2
    ply.canShoot = os.time() + option.playerCooldown
end

function wallHitSound()
    love.audio.stop(sounds.hit)
    love.audio.play(sounds.hit)
end

function playerSpeed(v) if math.abs(ply.xs + ply.ys) <= v then return true end end

function drawGame()
    setColorRGB(234, 236, 238)
    love.graphics.circle("fill", ply.x, ply.y, game.playerRadius)

    setColorRGB(255, 255, 255)
    love.graphics.setFont(Font12)
    love.graphics.print("Score: " ..ply.score.. " x" ..ply.destructionSeries.. " Best score: " ..option.bestScore, 10, 10)

    if ply.newScore ~= 0 then
        love.graphics.setFont(Font24)
        love.graphics.print("+" ..ply.newScore, game.width / 2 - Font24:getWidth("+" ..ply.newScore) / 2, game.height / 2 + Font24:getHeight("+" ..ply.newScore))
    end
end

function gameOver()
    retry:update()
    menu:update()

    local finalScore = ply.score * round(30 / option.objectsLimit, 0)

    if finalScore > option.bestScore then
        option.bestScore = finalScore
    end

    if retry:isPressed() then restart() end
    if menu:isPressed() then
        game.play = false
        game.menu = true
        restart()
    end
end

function drawGameOver()
    setColorRGB(0, 0, 0)

    love.graphics.setFont(Font24)
    love.graphics.print("You lose.", game.width / 2 - Font24:getWidth("You lose.") / 2, game.height / 2 - Font24:getHeight("You lose."))
    love.graphics.setFont(Font12)
    local finalScore = "Final score: " ..ply.score * round(30 / option.objectsLimit, 0)
    love.graphics.print(finalScore, game.width / 2 - Font12:getWidth(finalScore) / 2, game.height / 2 + Font12:getHeight(finalScore))
    love.graphics.setFont(Font24)

    setColorRGB(192, 57, 43)
    retry:draw("Retry")
    setColorRGB(241, 196, 15)
    menu:draw("Menu")
end
