require "libraries/quozul-tools"

local button = {}
button.__index = button

function newButton(x, y, width, height)
    local b = {}
    b.width = width
    b.height = height
    b.x = x
    b.y = y

    b.value = false

    return setmetatable(b, button)
end

function button:update()
    if click.isNew() and not self.value and buttonHover(self.x, self.y, self.width, self.height) then
        self.value = true
        love.audio.stop(sounds.uiClick)
        love.audio.play(sounds.uiClick)
    else
        self.value = false
    end
end

function button:draw(name)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    love.graphics.setColor(0, 0, 0)

    local Font = love.graphics.getFont()
    love.graphics.print(name, self.x + (self.width / 2 - Font:getWidth(name) / 2), self.y + (self.height / 2 - Font:getHeight(name) / 2))
end

function button:isPressed() return self.value end
