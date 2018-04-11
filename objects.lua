require "libraries/quozul-tools"

local objects = {}
objects.objects = {}
objects.particles = {}

local objectID = 0

function objectColor()
    local color = "white"
    local points = 1

    if percentage(3) then
        color, points = "red", 5
    elseif percentage(6) then
        color, points = "yellow", 4
    elseif percentage(12) then
        color, points = "green", 3
    elseif percentage(24) then
        color, points = "blue", 2
    elseif percentage(100) then
        color, points = "white", 1
    end

    return color, points
end

function addObject()
    local o = {}
    o.x = love.math.random(game.objectSize + game.xBorder, game.width - game.xBorder - game.objectSize)
    o.y = love.math.random(game.objectSize + game.yBorder, game.height - game.yBorder - game.objectSize)
    o.id = objectID
    objectID = objectID + 1

    o.xs, o.ys = 0, 0

    o.color, o.points = objectColor()
    o.hits = o.points

    game.objectsCount = game.objectsCount + 1
    table.insert(objects.objects, o)
end

function objectInReach()
    for _,i in pairs(objects.objects) do
        if segmentLengh(ply.x, ply.y, i.x, i.y) <= game.playerReach then
            return true
        end
    end
end

function selectClosestObject()
    local closestObject = game.width^2 + game.height^2
    local closestId = 0
    local cx, cy = 0, 0

    for _,i in pairs(objects.objects) do
        local objectDistance = segmentLengh(love.mouse.getX(), love.mouse.getY(), i.x, i.y)

        if objectDistance < closestObject and segmentLengh(ply.x, ply.y, i.x, i.y) <= game.playerReach then
            closestObject = objectDistance
            closestId = i.id
            cx, cy = i.x + game.objectSize / 2, i.y + game.objectSize / 2
        end
    end

    return closestId, cx, cy
end

function drawObjects()
    for _,i in pairs(objects.objects) do
        if i.color == "white" then setColorRGB(255, 255, 255)
        elseif i.color == "blue" then setColorRGB(133, 193, 233)
        elseif i.color == "green" then setColorRGB(46, 204, 113)
        elseif i.color == "yellow" then setColorRGB(241, 196, 15)
        elseif i.color == "red" then setColorRGB(192, 57, 43) end

        love.graphics.rectangle("fill", i.x, i.y, game.objectSize, game.objectSize)

        -- Debug
        --love.graphics.setFont(Font12)
        --love.graphics.setColor(0,0,0)
        --love.graphics.print(round(i.hits, 2), i.x, i.y)
    end
end

function drawLines()
    for _,i in pairs(objects.objects) do
        if i.id == selectClosestObject() then
            love.graphics.setColor(1, 1, 1, 1)
            segmentDraw(ply.x, ply.y, i.x + game.objectSize / 2, i.y + game.objectSize / 2)
        elseif segmentLengh(ply.x, ply.y, i.x, i.y) <= game.playerReach then
            love.graphics.setColor(1, 1, 1, 0.25)
            segmentDraw(ply.x, ply.y, i.x + game.objectSize / 2, i.y + game.objectSize / 2)
        end
    end
end

function explosion(x, y)
    for e,i in ipairs(objects.objects) do
        if segmentLengh(i.x, i.y, x, y) >= game.playerReach * 2 then
            if math.abs(i.xs + i.ys) < 0.001 then
                i.xs, i.ys = i.x - x, i.y - y
            end

            if not option.lessParticles then
                for n=option.maxParticles / 2,option.maxParticles do
                    addParticles(i.x, i.y, i.color)
                end
            end
        end
    end

    for n=option.maxParticles,option.maxParticles * 16 do
        addParticles(x, y, "red")
    end

    if not option.lessParticles then
        for n=option.maxParticles,option.maxParticles * 4 do
            addParticles(x, y, "orange")
        end
    end
end

function updateObjects() -- Remove an object on collision
    for e,i in ipairs(objects.objects) do
        if CheckCollision(ply.x, ply.y, game.playerRadius*2, game.playerRadius*2, i.x, i.y, game.objectSize, game.objectSize) then
            if math.abs(i.xs + i.ys) < 0.001 and math.abs(ply.xs + ply.ys) >= 0.0001 then
                i.xs, i.ys = ply.xs / 2, ply.ys / 2
                i.hits = i.hits - math.abs(i.xs + i.ys) / game.playerReach

                if not option.lessParticles then
                    for n=0, option.maxParticles / 4 * i.points do
                        addParticles(i.x + game.objectSize / 2, i.y + game.objectSize / 2, i.color)
                    end
                end
            end

        else
            i.xs, i.ys = i.xs / 1.3, i.ys / 1.3
            i.x, i.y = i.x + i.xs, i.y + i.ys
        end

        if i.x < game.xBorder then
            i.xs = -i.xs
            i.x = game.xBorder
        elseif i.x + game.objectSize > game.width - game.xBorder then
            i.xs = -i.xs
            i.x = game.height - game.xBorder - game.objectSize
        end

        if i.y < game.yBorder then
            i.y = -i.ys
            i.y = game.yBorder
        elseif i.y + game.objectSize > game.height - game.yBorder then
            i.y = -i.ys
            i.y = game.height - game.yBorder - game.objectSize
        end

        if math.abs(i.xs + i.ys) > i.points * 10 or i.hits <= 0 then
            table.remove(objects.objects, e)
            game.objectsCount = game.objectsCount - 1

            if i.color ~= "red" and math.abs(ply.xs + ply.ys) >= 0.01 then
                ply.score = ply.score + i.points * ply.destructionSeries

                for n=0, option.maxParticles * i.points do
                    addParticles(i.x, i.y, i.color)
                end

                love.audio.stop(sounds.hitObject)
                love.audio.play(sounds.hitObject)
            elseif i.color == "red" then
                explosion(i.x, i.y)

                love.audio.stop(sounds.explosion)
                love.audio.play(sounds.explosion)
            end

            ply.destructionSeries = ply.destructionSeries + 1
        end
    end
end

function clearObjects()
    for e,_ in ipairs(objects.objects) do
        table.remove(objects.objects, e)
    end

    game.objectsCount = 0
end

function addParticles(x, y, color)
    if love.timer.getFPS() >= 30 then
        p = {}
        p.x, p.y = x + love.math.random(0, game.objectsSize), y + love.math.random(0, game.objectsSize)
        p.color = color

        p.xs, p.ys = randomFloat(-2, 2, 6), randomFloat(-2, 2, 6)

        if color == "orange" then
            p.size = game.objectSize / 2
        else
            p.size = game.objectSize / 8
        end

        table.insert(objects.particles, p)
    end
end

function updateParticles()
    for e,p in ipairs(objects.particles) do
        p.x, p.y = p.x + p.xs, p.y + p.ys
        if option.gravity then p.ys = p.ys + 0.01 end
        if option.lessParticles and not option.infiniteParticles then
            p.size = p.size / 1.01
        elseif not option.infiniteParticles then
            p.size = p.size / 1.01
        end

        if not option.lessParticles then
            if p.x <= game.xBorder or p.x + p.size >= game.width - game.xBorder then p.xs = 0 end
            if p.y <= game.yBorder and not game.gravity or p.y + p.size >= game.height - game.yBorder then p.ys = 0 end
        else
            if p.x <= game.xBorder or p.x >= game.width - game.xBorder or p.y <= game.yBorder or p.y >= game.height - game.yBorder then table.remove(objects.particles, e) end
        end

        if p.xs == 0 and p.ys == 0 then table.remove(objects.particles, e)
        elseif not option.infiniteParticles and p.size <= 0.1 then table.remove(objects.particles, e) end
    end
end

function drawParticles()
    for _,p in pairs(objects.particles) do
        if p.color == "white" then setColorRGB(255, 255, 255)
        elseif p.color == "blue" then setColorRGB(133, 193, 233)
        elseif p.color == "green" then setColorRGB(46, 204, 113)
        elseif p.color == "yellow" then setColorRGB(241, 196, 15)
        elseif p.color == "orange" then setColorRGBa(214, 137, 16, 127)
        elseif p.color == "red" then setColorRGB(192, 57, 43) end

        love.graphics.rectangle("fill", p.x, p.y, p.size, p.size)
    end
end

function clearParticles()
    for e,p in ipairs(objects.particles) do
        table.remove(objects.particles, e)
    end
end
