require "vectools"

objects = {}
objects.objects = {}
objects.particles = {}

ply = {}

function love.load()
    canPush = true
    canPushTimer = 0
    gameOver = false
    minParts, maxParts = 10, 20

    objects.count = 0
    objects.lastSpacing = 1024
    objects.idClosest = 0
    objects.w = 20
    objects.closestAmount = 0
    ply.score = 0
                    --  w    h
    love.window.setMode(480, 640)
    love.window.setTitle("Dot destroyer - A game by Quôzul")
    game = {}
    game.width, game.height, game.flags = love.window.getMode()
    game.border = 50
    game.over = false
    game.overTries = 0

    ply.x = game.width / 2
    ply.y = game.height / 2
    ply.xspeed = 0
    ply.yspeed = 0

    -- sounds
    sounds = {}
    sounds.shoot = love.audio.newSource("sounds/shoot.ogg", "stream")
    sounds.wall = love.audio.newSource("sounds/wallhit.ogg", "stream")
    sounds.object = love.audio.newSource("sounds/objecthit.ogg", "stream")
end

function objects:add()
    obj = {}
    obj.id = love.math.random(objects.count, 32767)
    obj.x = love.math.random(objects.w + game.border, game.width - game.border - objects.w)
    obj.y = love.math.random(objects.w + game.border, game.height - game.border - objects.w)
    obj.golden = love.math.random(0, 1)

    objects.count = self.count + 1
    table.insert(self.objects, obj)
end

function createParticles(golden, x, y)
    part = {}
    part.golden = golden
    part.x = love.math.random(x - 10, x + 10)
    part.y = love.math.random(y - 10, y + 10)

    part.xspeed = randomFloat(-2, 2, 6)
    part.yspeed = randomFloat(-2, 2, 6)
    part.age = 255

    table.insert(objects.particles, part)
end

function hitWall() love.audio.stop(sounds.wall) love.audio.play(sounds.wall) end

function love.update(dt)
    game.width, game.height, game.flags = love.window.getMode()

    if objects.count <= 20 then
        objects:add()
    end

    if love.mouse.isDown(1) and canPush then
        for e,i in ipairs(objects.objects) do
            if objects.idClosest == i.id then
                table.remove(objects.objects, e)
                objects.count = objects.count - 1

                ply.xspeed = i.x - ply.x
                ply.yspeed = i.y - ply.y

                if i.golden == 1 then
                    ply.score = ply.score + 1

                    for n=10,love.math.random(minParts, maxParts) do
                            createParticles(true, i.x, i.y)
                    end
                else
                    for n=10,love.math.random(minParts, maxParts) do
                        createParticles(false, i.x, i.y)
                    end
                end

                love.audio.stop(sounds.shoot)
                love.audio.stop(sounds.object)
                love.audio.play(sounds.shoot)
                love.audio.play(sounds.object)
            end
        end

        canPush = false
        canPushTimer = 0
    end

    -- movements and collisions
    ply.x = ply.x + ply.xspeed
    ply.y = ply.y + ply.yspeed

    ply.xspeed = ply.xspeed / 1.3
    ply.yspeed = ply.yspeed / 1.3

    if ply.x >= game.width - game.border then
        ply.xspeed = -ply.xspeed
        ply.x = game.width - game.border
        hitWall()
    elseif ply.x <= game.border then
        ply.xspeed = -ply.xspeed
        ply.x = game.border
        hitWall()
    end

    if ply.y >= game.height - game.border then
        ply.yspeed = -ply.yspeed
        ply.y = game.height - game.border
        hitWall()
    elseif ply.y <= game.border then
        ply.yspeed = -ply.yspeed
        ply.y = game.border
        hitWall()
    end

    canPushTimer = canPushTimer + 1
    if canPushTimer >= 20 then
        canPush = true
    end

    -- select the closest object
    for _,i in pairs(objects.objects) do
        if vector.lengh(love.mouse.getX(), love.mouse.getY(), i.x, i.y) < objects.lastSpacing and vector.lengh(ply.x, ply.y, i.x, i.y) <= 128 then
            objects.lastSpacing = vector.lengh(love.mouse.getX(), love.mouse.getY(), i.x, i.y)
            objects.idClosest = i.id
        elseif vector.lengh(love.mouse.getX(), love.mouse.getY(), i.x, i.y) < objects.lastSpacing and vector.lengh(ply.x, ply.y, i.x, i.y) > 128 then
            objects.idClosest = 0
        end

        if vector.lengh(ply.x, ply.y, i.x, i.y) <= 128 then
            objects.closestAmount = objects.closestAmount + 1
        end
    end

    if objects.closestAmount <= 0 then
        game.overTries = game.overTries + 1
    else
        game.overTries = 0
    end

    if game.overTries >= 10 then
        game.over = true
    else
        game.over = false
    end

    if game.overTries >= 128 then
        for e,i in ipairs(objects.objects) do
            table.remove(objects.objects, e)
            objects.count = objects.count - 1
        end
        game.overTries = 0
        ply.score = 0
    end

    objects.lastSpacing = 128
    objects.closestAmount = 0

    -- particles
    for e,i in ipairs(objects.particles) do
        i.x = i.x + i.xspeed
        i.y = i.y + i.yspeed

        i.age = i.age - 1
        if i.age <= 0 then
            table.remove(objects.particles, e)
        end
    end
end

function love.draw()
    love.graphics.setBackgroundColor(23, 32, 42)
    love.graphics.setColor(44, 62, 80)
    love.graphics.rectangle("fill", game.border, game.border, game.width - game.border * 2, game.height - game.border * 2)

    love.graphics.print("Score: " ..ply.score, 10, 10)

    -- draw particles
    for _,i in pairs(objects.particles) do
        if i.golden then
            love.graphics.setColor(241, 196, 15, i.age)
        else
            love.graphics.setColor(253, 254, 254, i.age)
        end
        love.graphics.rectangle("fill", i.x - 1, i.y - 1, 2, 2)
        love.graphics.setColor(255, 255, 255)
    end

    for _,i in pairs(objects.objects) do
        -- draw lines
        if vector.lengh(ply.x, ply.y, i.x, i.y) <= 128 then
            love.graphics.setColor(255, 255, 255, 127)
            vector.draw(ply.x, ply.y, i.x, i.y)
        end

        if objects.idClosest == i.id then
            love.graphics.setColor(255, 255, 255)
            vector.draw(ply.x, ply.y, i.x, i.y)
        end

        -- draw bricks
        if i.golden == 1 then
            love.graphics.setColor(241, 196, 15)
        else
            love.graphics.setColor(253, 254, 254)
        end
        love.graphics.rectangle("fill", i.x - 10, i.y - 10, objects.w, objects.w)

        love.graphics.setColor(255, 255, 255)
    end

    love.graphics.setColor(171, 178, 185)
    love.graphics.circle("fill", ply.x, ply.y, 10) -- draw player

    -- game over
    if game.over then
        love.graphics.print("No blocks in range...\nGame is over.\nYour score is " ..ply.score, game.width / 3, game.height / 3)
    end
end
