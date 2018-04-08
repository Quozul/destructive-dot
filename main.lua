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

    game.objectSize = 20 -- In pixels
    game.playerRadius = 10 -- Radius of the ball in pixels
    game.playerReach = 120 -- Reach in pixels

    -- Window variables
    game.xBorder, game.yBorder = 20, 40

    -- Settings parameters
    game.objectsLimit = 15
    game.maxParticles = 15

    -- Gameplay
    game.playerCooldown = 1 -- Cooldown in seconds

    game.lessParticles = false
    game.infiniteParticles = false
    game.gravity = false

    -- Player variables
    ply.score = 0
    ply.destructionSeries = 1 -- Must be at least 1
    ply.shots = 0 -- Number of shots done by the player
    ply.canShoot = os.time() -- Define when the player can shoot

    game.bestScore = 0
    game.showFPS = false

    if love.getVersion() == 11 then load() end

    game.width, game.height = love.window.getMode()

    if love.system.getOS() == "iOS" or love.system.getOS() == "Android" and love.getVersion() == 11 then
        game.width, game.height = game.width / 2, game.height / 2
    end

    LFont = love.graphics.newFont("data/Montserrat-Regular.ttf", game.height / 2)

    ply.x, ply.y = game.width / 2, game.height / 2
    ply.xs, ply.ys = 0, 0

    -- Settings up the window
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
    local buttonHeight = game.height / 6
    local buttonWidth = game.width / 4

    retry = newButton(game.width / 2 - buttonWidth / 2, game.height / 2 - buttonHeight * 1.5, buttonWidth, buttonHeight)
    menu = newButton(game.width / 2 - buttonWidth / 2, game.height / 2 + buttonHeight / 2, buttonWidth, buttonHeight)

    play = newButton(game.width / 2 - buttonWidth / 2, game.height / 2 - buttonHeight * 2, buttonWidth, buttonHeight)
    settings = newButton(game.width / 2 - buttonWidth / 2, game.height / 2 - buttonHeight / 2, buttonWidth, buttonHeight)
    quit = newButton(game.width / 2 - buttonWidth / 2, game.height / 2 + buttonHeight, buttonWidth, buttonHeight)

    back = newButton(game.width - Font12:getWidth("← Back") * 2 - 10, 10, Font12:getWidth("← Back") * 2, Font12:getHeight("← Back") * 2)

    -- Sliders
    difficultySlider = newSlider(game.width / 2, 100, 200, game.objectsLimit, 30, 5, {width=15, orientation='horizontal', track='roundrect', knob='circle'})
    particlesSlider = newSlider(game.width / 2, 200, 200, game.maxParticles, 0, 150, {width=15, orientation='horizontal', track='roundrect', knob='circle'})

    -- Checkboxes
    lessParticles = newCheckbox(10, game.height / 2 + 30)
    infiniteParticles = newCheckbox(10, game.height / 2)
    fullscreen = newCheckbox(game.width - 30, game.height / 2)
    showFPS = newCheckbox(game.width - 30, game.height / 2 + 30)

    fullscreen:checkValue(love.window.getFullscreen())
    lessParticles:checkValue(game.lessParticles)
    infiniteParticles:checkValue(game.infiniteParticles)
    showFPS:checkValue(game.showFPS)
end

function love.mousepressed(x, y, button, isTouch)
    if button == 1 and ply.canShoot <= os.time() and not game.over and game.play and not game.menu and not isTouch then
        local id, px, py = selectClosestObject()
        ply.xs = px - ply.x
        ply.ys = py - ply.y

        ply.canShoot = os.time() + game.playerCooldown
        ply.shots = ply.shots + 1

        love.audio.stop(sounds.shoot)
        love.audio.play(sounds.shoot)
    end
end

function love.mousereleased(x, y, button, isTouch)
    if button == 1 and ply.canShoot <= os.time() and not game.over and game.play and not game.menu and isTouch then
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
    if key == "escape" or key == "appback" then
        if game.play then
            game.play, game.menu = false, true
        elseif game.settings then
            game.settings, game.menu = false, true
        elseif game.menu then
            love.event.quit()
        end
    end
end

function love.update(dt)
    if love.timer.getFPS() <= 15 then
        clearParticles()
    end

    if love.window.hasFocus() then
        click.update()

        if game.bestScore < ply.score then game.bestScore = ply.score end

        if not game.play and game.menu and not game.settings then menuUpdate()
        elseif game.play then gameUpdate()
        elseif not game.play and not game.menu and game.settings then settingsUpdate() end
        if game.over then gameOver() end
    end
end

function love.draw()
    love.graphics.setBackgroundColor(23/255, 32/255, 42/255)

    if not game.play and game.menu and not game.settings then
        menuDraw()
    elseif game.play and not game.menu then
        setColorRGB(44, 62, 80)
        love.graphics.rectangle("fill", game.xBorder, game.yBorder, game.width - game.xBorder * 2, game.height - game.yBorder * 2)

        setColorRGB(86, 101, 115)
        love.graphics.setFont(LFont)
        love.graphics.print(ply.score, game.width / 2 - LFont:getWidth(ply.score) / 2, game.height / 2 - LFont:getHeight(ply.score) / 2)

        drawParticles()
        drawLines()
        drawObjects()
        drawGame()
    elseif not game.play and not game.menu and game.settings then
        settingsDraw()
    end
    if game.over and not game.menu and not game.settings then
        drawGameOver()
    end

    love.graphics.setColor(1, 1, 1)
    if love.system.getOS() == "Windows" or love.system.getOS() == "Linux" or love.system.getOS() == "OS X" then
        love.graphics.draw(images.cursor, love.mouse.getX(), love.mouse.getY())
    end

    -- FPS
    if game.showFPS then
        local fps = "Current FPS: " ..tostring(love.timer.getFPS())
        love.graphics.setFont(Font12)
        love.graphics.print(fps, game.width - Font12:getWidth(fps) - 10, 10)
    end

    if love.getVersion() ~= 11 then
        love.graphics.setColor(255, 0, 0)
        love.graphics.setFont(Font24)
        local msg = "You're not in the right version of Löve 2D"
        love.graphics.print(msg, game.width / 2 - Font24:getWidth(msg) / 2, game.height / 2 - Font24:getHeight(msg) / 2)
    end
end

function love.quit() save() end

function save()
    love.filesystem.remove("save.sav")
    love.filesystem.write("save.sav", serialize(game))
end

function load()
    if love.filesystem.getInfo( "save.sav" ) then
        chunk = love.filesystem.load("save.sav")
        game = chunk()
    end
end
