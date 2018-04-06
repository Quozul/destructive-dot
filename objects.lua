require "libraries/quozul-tools"

local objects = {}
objects.objects = {}
objects.particles = {}

local objectID = 0

function objectColor()
    local color = "white"
    local points = 1

    if percentage(48) then
        color, points = "white", 1
    elseif percentage(24) then
        color, points = "blue", 2
    elseif percentage(12) then
        color, points = "green", 3
    elseif percentage(6) then
        color, points = "yellow", 4
    elseif percentage(3) then
        color = "red"
    end

    return color, points
end

function addObject()
    local o = {}
    o.x = love.math.random(game.objectSize + game.xBorder, game.width - game.xBorder - game.objectSize)
    o.y = love.math.random(game.objectSize + game.yBorder, game.height - game.yBorder - game.objectSize)
    o.id = objectID
    objectID = objectID + 1

    o.color, o.points = objectColor()

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
    end
end

function drawLines()
    for _,i in pairs(objects.objects) do
        if i.id == selectClosestObject() then
            love.graphics.setColor(255,255,255,255)
            segmentDraw(ply.x, ply.y, i.x + game.objectSize / 2, i.y + game.objectSize / 2)
        elseif segmentLengh(ply.x, ply.y, i.x, i.y) <= game.playerReach then
            love.graphics.setColor(255,255,255,64)
            segmentDraw(ply.x, ply.y, i.x + game.objectSize / 2, i.y + game.objectSize / 2)
        end
    end
end

function explosion(x, y)
    for e,i in ipairs(objects.objects) do
        table.remove(objects.objects, e)
        game.objectsCount = game.objectsCount - 1
        ply.score = ply.score + i.points * ply.destructionSeries

        ply.destructionSeries = ply.destructionSeries + 1
    end

    for n=game.maxParticles,game.maxParticles * 8 do
        addParticles(x, y, "red")
    end
end

function removeObject() -- Remove an object on collision
    for e,i in ipairs(objects.objects) do
        if CheckCollision(ply.x, ply.y, game.playerRadius*2, game.playerRadius*2, i.x, i.y, game.objectSize, game.objectSize) then
            table.remove(objects.objects, e)
            game.objectsCount = game.objectsCount - 1

            if i.color ~= "red" then
                ply.score = ply.score + i.points * ply.destructionSeries

                for n=game.maxParticles / 2,game.maxParticles * i.points do
                    addParticles(i.x, i.y, i.color)
                end

                love.audio.stop(sounds.hitObject)
                love.audio.play(sounds.hitObject)
            else
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
    p = {}
    p.x, p.y = x, y
    p.color = color
    p.xs, p.ys = randomFloat(-2, 2, 6), randomFloat(-2, 2, 6)
    p.age = 127

    table.insert(objects.particles, p)
end

function updateParticles()
    for e,p in ipairs(objects.particles) do
        p.x, p.y = p.x + p.xs, p.y + p.ys
        p.age = p.age - 1

        if p.x <= game.xBorder or p.x + game.objectSize / 8 >= game.width - game.xBorder or p.y <= game.yBorder or p.y + game.objectSize / 8 >= game.height - game.yBorder then
            table.remove(objects.particles, e)
        elseif p.xs == 0 and p.ys == 0 then table.remove(objects.particles, e)
        elseif p.age == 0 then table.remove(objects.particles, e) end
    end
end

function drawParticles()
    for _,p in pairs(objects.particles) do
        if p.color == "white" then setColorRGBa(255, 255, 255, p.age * 2)
        elseif p.color == "blue" then setColorRGBa(133, 193, 233, p.age * 2)
        elseif p.color == "green" then setColorRGBa(46, 204, 113, p.age * 2)
        elseif p.color == "yellow" then setColorRGBa(241, 196, 15, p.age * 2)
        elseif p.color == "red" then setColorRGBa(192, 57, 43, p.age * 4) end

        love.graphics.rectangle("fill", p.x, p.y, game.objectSize / 8, game.objectSize / 8)
    end
end
