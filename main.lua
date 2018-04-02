require "tools"
require "menu"
require "library/simple-slider"
require "game"
local bitser = require 'library/bitser'
local serialize = require 'library/ser'

objects = {}
objects.objects = {}
objects.particles = {}

game = {}
ply = {}

function love.load()
    gameFont = love.graphics.newFont( "data/Montserrat-Regular.ttf", 12 ) -- Font from Google Font

    canPush = true
    canPushTimer = 0
    minParts, maxParts = 10, 20

    objects.count = 0
    objects.limit = 20
    objects.lastSpacing = 128
    objects.idClosest = 0
    objects.w = 20
    objects.closestAmount = 0
    ply.score = 0
    ply.bestScore = 0
                    --  w    h
    love.window.setMode(480, 640)
    love.window.setTitle("Destructive Dot - A game by Quôzul")
    game = {}
    game.width, game.height, game.flags = love.window.getMode()
    game.border = 50
    game.over = false
    game.overTries = 0

    ply.x = game.width / 2
    ply.y = game.height / 2
    ply.xspeed = 0
    ply.yspeed = 0
    ply.destructionSeries = 1
    ply.radius = 10

    -- sounds
    sounds = {}
    sounds.shoot = love.audio.newSource("data/shoot.ogg", "stream")
    sounds.wall = love.audio.newSource("data/wallhit.ogg", "stream")
    sounds.object = love.audio.newSource("data/objecthit.ogg", "stream")
    sounds.click = love.audio.newSource("data/click.ogg", "stream")
    -- images
    images = {}
    images.pause = love.graphics.newImage("data/pause.png")
    images.cursor = love.graphics.newImage("data/cursor.png")
    images.menu = love.graphics.newImage("data/menu.png")

    icon = love.image.newImageData("icon.png")
    love.window.setIcon(icon)

    love.mouse.setVisible(false)

    game.start = false
    game.settings = false
    load()
end

function objects:add()
    obj = {}
    obj.id = love.math.random(0, 32767)
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

function love.update(dt)
    if ply.score > ply.bestScore then ply.bestScore = ply.score end

    if game.start then
        game.width, game.height, game.flags = love.window.getMode()

        if objects.count <= objects.limit then
            objects:add()
        end

        removeObject()
        movements()

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
            game.start = false
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

        if love.keyboard.isDown("escape") then
            game.start = false
        end

        if buttonHover(game.width - 32, 6, 21, 22) and click() then
            canPush = false
            canPushTimer = 0
            love.audio.stop(sounds.click)
            love.audio.play(sounds.click)
            game.start = false
        end

    else
        menu()
    end
end

function love.mousepressed(x, y, button, isTouch)
    if button == 1 and canPush then
        for _,i in ipairs(objects.objects) do
            if objects.idClosest == i.id then

                ply.xspeed = i.x - ply.x
                ply.yspeed = i.y - ply.y

                love.audio.stop(sounds.shoot)
                love.audio.play(sounds.shoot)
            end
        end

        canPush = false
        canPushTimer = 0
    end
end

function love.draw()
    love.graphics.setFont( gameFont )
    love.graphics.setBackgroundColor(23/255, 32/255, 42/255)

    if game.start then
        love.graphics.draw(images.pause, game.width - 32, 6)

        setColorRGB(44, 62, 80)
        love.graphics.rectangle("fill", game.border, game.border, game.width - game.border * 2, game.height - game.border * 2)

        love.graphics.print("Score: " ..ply.score.. " Best Score: " ..ply.bestScore, 10, 10)

        -- draw particles
        for _,i in pairs(objects.particles) do
            if i.golden then
                setColorRGB(241, 196, 15, i.age)
            else
                setColorRGB(253, 254, 254, i.age)
            end
            love.graphics.rectangle("fill", i.x - 1, i.y - 1, 2, 2)
            setColorRGB(255, 255, 255)
        end

        for _,i in pairs(objects.objects) do
            -- draw lines
            if vector.lengh(ply.x, ply.y, i.x, i.y) <= 128 then
                setColorRGB(255, 255, 255, 127)
                vector.draw(ply.x, ply.y, i.x, i.y)
            end

            if objects.idClosest == i.id then
                setColorRGB(255, 255, 255)
                vector.draw(ply.x, ply.y, i.x, i.y)
            end

            -- draw bricks
            if i.golden == 1 then
                setColorRGB(241, 196, 15)
            else
                setColorRGB(253, 254, 254)
            end
            love.graphics.rectangle("fill", i.x - 10, i.y - 10, objects.w, objects.w)

            setColorRGB(255, 255, 255)
        end

        setColorRGB(171, 178, 185)
        love.graphics.circle("fill", ply.x, ply.y, ply.radius) -- draw player

        -- game over
        if game.over then
            love.graphics.print("No blocks in radius...\nYour game is over.\nYour score was " ..ply.score, game.width / 3, game.height / 3)
        end
    else
        drawmenu()
    end
    setColorRGB(255, 255, 255)
    love.graphics.draw(images.cursor, love.mouse.getX() - 4, love.mouse.getY() - 4)
end

-- Saving part

function love.quit()
    saving()
end

function saving()
    save = {}
    save.objectsLimit = objects.limit
    save.bestScore = ply.bestScore
    save.particles = (minParts + maxParts) / 2
    if not love.filesystem.getInfo("quozul-games") then love.filesystem.createDirectory("quozul-games") end
    love.filesystem.write("quozul-games/destructive-dot.sav", serialize(save))
end

function load()
    if not love.filesystem.getInfo( "quozul-games/destructive-dot.sav" ) then
        saving()
        love.event.quit("restart")
    end
    if love.filesystem.getInfo( "quozul-games/destructive-dot.sav" ) then
        chunk = love.filesystem.load("quozul-games/destructive-dot.sav")
        loaded = chunk()
        minParts, maxParts = loaded.particles - 5, loaded.particles + 5
        objects.limit = loaded.objectsLimit
        ply.bestScore = loaded.bestScore
    end
end
