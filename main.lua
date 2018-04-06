require "objects"
require "game"
require "menu"

require "libraries/quozul-tools" -- By Quôzul
require "libraries/simple-button" -- By Quôzul

game = {}
ply = {}

function love.load()
    icon = love.image.newImageData("icon.png")
    love.window.setIcon(icon)

    love.mouse.setVisible(false) -- Hide cursor

    Font12 = love.graphics.newFont("data/Montserrat-Regular.ttf", 24) -- Font from Google Font
    Font24 = love.graphics.newFont("data/Montserrat-Regular.ttf", 48)

    -- Window variables
    game.xBorder, game.yBorder = 40, 80

    -- Settings parameters
    game.objectsLimit = 15
    game.maxParticles = 5

    -- Gameplay
    game.objectSize = 40 -- In pixels
    game.playerRadius = 20 -- Radius of the ball in pixels
    game.playerReach = 240 -- Reach in pixels
    game.playerCooldown = 1 -- Cooldown in seconds

    -- Player variables
    ply.score = 0
    ply.destructionSeries = 1 -- Must be at least 1
    ply.shots = 0 -- Number of shots done by the player
    ply.canShoot = os.time() -- Define when the player can shoot

    bestScore = 0

    game.width, game.height = love.window.getMode()

    ply.x, ply.y = game.width / 2, game.height / 2
    ply.xs, ply.ys = 0, 0

    -- Settings up the window
    love.window.setTitle("Destructive Dot - A game by Quôzul")

    -- Menu identifier
    game.play = false
    game.menu = true
    game.over = false

    game.objectsCount = 0

    -- Loading sounds
    sounds = {}
    sounds.shoot = love.audio.newSource("data/shoot.ogg", "stream")
    sounds.hitWall = love.audio.newSource("data/wallhit.ogg", "stream")
    sounds.hitObject = love.audio.newSource("data/objecthit.ogg", "stream")
    sounds.uiClick = love.audio.newSource("data/click.ogg", "stream")
    sounds.explosion = love.audio.newSource("data/explosion.ogg", "stream")

    -- Buttons
    retry = newButton(game.width / 2 - 200, game.height / 2 - 250, 400, 200)
    menu = newButton(game.width / 2 - 200, game.height / 2 + 50, 400, 200)

    play = newButton(game.width / 2 - 200, game.height / 2 - 200, 400, 200)
    quit = newButton(game.width / 2 - 200, game.height / 2 + 50, 400, 200)
end

function love.mousereleased(x, y, button, isTouch)
    if button == 1 and ply.canShoot <= os.time() and not game.over and game.play and not game.menu then
        local id, px, py = selectClosestObject()
        ply.xs = px - ply.x
        ply.ys = py - ply.y

        ply.canShoot = os.time() + game.playerCooldown
        ply.shots = ply.shots + 1

        love.audio.stop(sounds.shoot)
        love.audio.play(sounds.shoot)
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        love.event.quit()
    end
end

function love.update(dt)
    click.update()

    local windowWidth, windowHeight = love.window.getMode()

    if game.width ~= windowWidth and game.height ~= windowHeight then
        game.width, game.height = love.window.getMode()
    end

    if bestScore < ply.score then bestScore = ply.score end

    if not game.play and game.menu and not game.settings then menuUpdate()
    elseif game.play then gameUpdate() end
    if game.over then gameOver() end
end

function love.draw()
    love.graphics.setBackgroundColor(23, 32, 42)

    if not game.play and game.menu and not game.settings then
        menuDraw()
    elseif game.play and not game.menu then
        drawGame()
        drawLines()
        drawObjects()
        drawParticles()
    end
    if game.over and not game.menu and not game.settings then
        drawGameOver()
    end
end

function love.quit() save() end

function save()
    love.filesystem.write("save.sav", bestScore)
end

function load()
    if love.filesystem.getInfo( "save.sav" ) then
        chunk = love.filesystem.load("save.sav")
        bestScore = chunk()
    end
end
