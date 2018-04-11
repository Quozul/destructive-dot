require "objects"
require "game"
require "menu"

require "libraries/quozul-tools" -- By Quôzul
require "libraries/simple-slider"
require "libraries/simple-button" -- By Quôzul
require "libraries/simple-checkbox" -- By Quôzul
local serialize = require 'libraries/ser'

option = {}
game = {}
ply = {}

function love.load()
    icon = love.image.newImageData("icon.png")
    love.window.setIcon(icon)

    love.mouse.setVisible(false) -- Hide cursor

    -- Settings parameters
    option.objectsLimit = 15
    option.maxParticles = 15

    -- Gameplay
    option.playerCooldown = 1 -- Cooldown in seconds

    option.lessParticles = false
    option.infiniteParticles = false
    option.gravity = false -- Secret feature
    option.playMusic = false -- Needs a button

    option.bestScore = 0
    option.showFPS = false
    option.fullscreen = true

    -- Player variables
    ply.score = 0
    ply.destructionSeries = 1 -- Must be at least 1
    ply.shots = 0 -- Number of shots done by the player
    ply.canShoot = os.time() -- Define when the player can shoot

    if love.getVersion() == 11 then load() end

    game.width, game.height = love.window.getMode()

    if love.system.getOS() == "iOS" or love.system.getOS() == "Android" and love.getVersion() == 11 then
        game.width, game.height = game.width / 2, game.height / 2
        game.lessParticles = true
        game.currentOS = "smartphone"
        game.size = (game.width * game.height) * 2
    else
        love.window.setFullscreen(option.fullscreen)
        game.width, game.height = love.window.getMode()
        game.size = game.width * game.height
    end

    game.objectSize = game.size / 24000 -- In pixels
    game.playerRadius = game.size / 48000 -- Radius of the ball in pixels
    game.playerReach = game.size / 4000 -- Reach in pixels

    checkboxSize = game.size / 24000

    -- Window variables
    game.xBorder, game.yBorder = game.size / 48000, game.size / 24000

    Font12 = love.graphics.newFont("data/Montserrat-Regular.ttf", game.size / 40000) -- Font from Google Font
    Font24 = love.graphics.newFont("data/Montserrat-Regular.ttf", game.size / 20000)

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
    sounds.shoot = love.audio.newSource("data/sounds/shoot.ogg", "stream")
    sounds.hitWall = love.audio.newSource("data/sounds/wallhit.ogg", "stream")
    sounds.hitObject = love.audio.newSource("data/sounds/wallhit.ogg", "stream") -- Must be changed
    sounds.uiClick = love.audio.newSource("data/sounds/click.ogg", "stream")
    sounds.explosion = love.audio.newSource("data/sounds/explosion.ogg", "stream")
    sounds.objectDestruction = love.audio.newSource("data/sounds/objectdestruction.ogg", "stream")

    musics = {}
    musics.banane = love.audio.newSource("data/musics/Banane.mp3", "stream")
    musics.framboise = love.audio.newSource("data/musics/Framboise.mp3", "stream")
    playMusic = 0

    -- Loading images
    images = {}
    love.graphics.setDefaultFilter("nearest", "nearest")
    images.pause = love.graphics.newImage("data/images/pause.png")
    images.cursor = love.graphics.newImage("data/images/cursor.png")

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
    difficultySlider = newSlider(game.width / 2, game.size / 24000 * 2, game.width / 4, option.objectsLimit, 30, 5, {width=game.size / 24000, orientation='horizontal', track='roundrect', knob='circle'})
    particlesSlider = newSlider(game.width / 2, game.size / 24000 * 4, game.width / 4, option.maxParticles, -1, 150, {width=game.size / 24000, orientation='horizontal', track='roundrect', knob='circle'})

    -- Checkboxes
    lessParticles = newCheckbox(checkboxSize * 2, game.height / 2 + checkboxSize * 2)
    infiniteParticles = newCheckbox(checkboxSize * 2, game.height / 2)
    fullscreen = newCheckbox(game.width - checkboxSize * 2, game.height / 2)
    showFPS = newCheckbox(game.width - checkboxSize * 2, game.height / 2 + checkboxSize * 2)

    fullscreen:checkValue(love.window.getFullscreen())
    lessParticles:checkValue(option.lessParticles)
    infiniteParticles:checkValue(option.infiniteParticles)
    showFPS:checkValue(option.showFPS)
end

function love.mousepressed(x, y, button, isTouch)
    if button == 1 and playerSpeed(0.1) and not game.over and game.play and not game.menu and not isTouch then
        local id, px, py = selectClosestObject()
        ply.xs = px - ply.x
        ply.ys = py - ply.y

        ply.canShoot = os.time() + option.playerCooldown
        ply.shots = ply.shots + 1

        love.audio.stop(sounds.shoot)
        love.audio.play(sounds.shoot)
    end
end

function love.mousereleased(x, y, button, isTouch)
    if button == 1 and playerSpeed(0.1) and not game.over and game.play and not game.menu and isTouch then
        local id, px, py = selectClosestObject()
        ply.xs = px - ply.x
        ply.ys = py - ply.y

        ply.canShoot = os.time() + option.playerCooldown
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

        if option.bestScore < ply.score then option.bestScore = ply.score end

        if not game.play and game.menu and not game.settings then menuUpdate()
        elseif game.play then gameUpdate()
        elseif not game.play and not game.menu and game.settings then settingsUpdate() end
        if game.over then gameOver() end
    end

    if love.audio.getActiveSourceCount() == 0 and option.playMusic then
        playMusic = playMusic + 1
    else playMusic = 0 end

    if playMusic >= 20 then
        local r = love.math.random(0, 1)
        if r == 0 then
            love.audio.play(musics.banane)
        elseif r == 1 then
            love.audio.play(musics.framboise)
        end
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
        local d = game.size / 1920000
        love.graphics.draw(images.cursor, love.mouse.getX() - images.cursor:getWidth() / 2 * d, love.mouse.getY() - images.cursor:getHeight() / 2 * d, 0, d, d)
    end

    -- FPS
    if option.showFPS then
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
    love.filesystem.write("save.sav", serialize(option))
end

function load()
    if love.filesystem.getInfo( "save.sav" ) then
        chunk = love.filesystem.load("save.sav")
        option = chunk()
    end
end
