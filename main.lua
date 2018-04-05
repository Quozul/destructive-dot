require "objects"
require "game"
require "menu"

require "libraries/quozul-tools" -- By Quôzul
require "libraries/simple-slider"
require "libraries/simple-button" -- By Quôzul
require "libraries/simple-checkbox" -- By Quôzul
local serialize = require 'libraries/ser'

game = {}
ply = {}

function love.load()
    icon = love.image.newImageData("icon.png")
    love.window.setIcon(icon)

    love.mouse.setVisible(false) -- Hide cursor

    Font12 = love.graphics.newFont("data/Montserrat-Regular.ttf", 12) -- Font from Google Font
    Font24 = love.graphics.newFont("data/Montserrat-Regular.ttf", 24)

    -- Window variables
    game.width, game.height = 480, 640
    game.xBorder, game.yBorder = 20, 40

    -- Settings parameters
    game.objectsLimit = 15
    game.maxParticles = 15

    -- Gameplay
    game.objectSize = 20 -- In pixels
    game.playerRadius = 10 -- Radius of the ball in pixels
    game.playerReach = 120 -- Reach in pixels
    game.playerCooldown = 1 -- Cooldown in seconds

    -- Player variables
    ply.score = 0
    ply.destructionSeries = 1 -- Must be at least 1
    ply.shots = 0 -- Number of shots done by the player
    ply.canShoot = os.time() -- Define when the player can shoot

    ply.x, ply.y = game.width / 2, game.height / 2
    ply.xs, ply.ys = 0, 0

    load()

    -- Settings up the window
    love.window.setMode(game.width, game.height, {resizable=true, minwidth=480, minheight=640})
    love.window.setTitle("Destructive Dot - A game by Quôzul")

    -- Menu identifier
    game.play = false
    game.menu = true
    game.settings = false
    game.over = false

    game.objectsCount = 0

    -- Loading sounds
    sounds = {}
    sounds.shoot = love.audio.newSource("data/shoot.ogg", "stream")
    sounds.hitWall = love.audio.newSource("data/wallhit.ogg", "stream")
    sounds.hitObject = love.audio.newSource("data/objecthit.ogg", "stream")
    sounds.uiClick = love.audio.newSource("data/click.ogg", "stream")
    sounds.explosion = love.audio.newSource("data/explosion.ogg", "stream")

    -- Loading images
    images = {}
    images.pause = love.graphics.newImage("data/pause.png")
    images.cursor = love.graphics.newImage("data/cursor.png")
    images.menu = love.graphics.newImage("data/menu.png")

    -- Buttons
    retry = newButton(game.width / 2 - 100, game.height / 2 - 150, 200, 100)
    menu = newButton(game.width / 2 - 100, game.height / 2 + 50, 200, 100)

    play = newButton(game.width / 2 - 100, game.height / 2 - 200, 200, 100)
    settings = newButton(game.width / 2 - 100, game.height / 2 - 50, 200, 100)
    quit = newButton(game.width / 2 - 100, game.height / 2 + 100, 200, 100)

    back = newButton(game.width - Font12:getWidth("← Back") * 2 - 10, 10, Font12:getWidth("← Back") * 2, Font12:getHeight("← Back") * 2)

    -- Sliders
    difficultySlider = newSlider(game.width / 2, 100, 200, game.objectsLimit, 30, 5, {width=15, orientation='horizontal', track='roundrect', knob='circle'})
    particlesSlider = newSlider(game.width / 2, 200, 200, game.maxParticles, 0, 150, {width=15, orientation='horizontal', track='roundrect', knob='circle'})

    -- Checkboxes
    fullscreen = newCheckbox(10, 10)

end

function love.mousepressed(x, y, button, isTouch)
    if button == 1 and ply.canShoot <= os.time() and not game.over and game.play then
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

    if game.play then gameUpdate()
    elseif not game.play and not game.settings then menuUpdate()
    elseif not game.play and not game.menu and game.settings then settingsUpdate() end
    if game.over then gameOver() end
end

function love.draw()

    love.graphics.setBackgroundColor(23/255, 32/255, 42/255)

    if game.play and not game.menu then
        drawGame()
        drawLines()
        drawObjects()
        drawParticles()
    elseif not game.play and game.menu and not game.settings then
        menuDraw()
    elseif not game.play and not game.menu and game.settings then
        settingsDraw()
    end
    if game.over and not game.menu and not game.settings then
        drawGameOver()
    end

    setColorRGB(255,255,255)
    love.graphics.draw(images.cursor, love.mouse.getX(), love.mouse.getY())

    -- Debug
    --love.graphics.print(boolToNumber(game.play).." "..boolToNumber(game.menu).." "..boolToNumber(game.over), 10, 50)
end

function love.quit() save() end

function save()
    love.filesystem.write("save.sav", serialize(game))
end

function load()
    if love.filesystem.getInfo( "save.sav" ) then
        chunk = love.filesystem.load("save.sav")
        game = chunk()
    end
end
