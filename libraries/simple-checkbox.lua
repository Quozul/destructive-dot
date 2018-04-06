require "libraries/quozul-tools"

local checkbox = {}
checkbox.__index = checkbox

local checkboxSize = 20

function newCheckbox(x, y)
    local c = {}
    c.x = x
    c.y = y

    c.value = false

    return setmetatable(c, checkbox)
end

function checkbox:update()
    if click.isNew() and buttonHover(self.x, self.y, checkboxSize, checkboxSize) then
        self.value = not self.value
        love.audio.stop(sounds.uiClick)
        love.audio.play(sounds.uiClick)
    end
end

function checkbox:draw(name)
    if not self.value then
        love.graphics.rectangle("line", self.x, self.y, checkboxSize, checkboxSize)
    else
        love.graphics.rectangle("fill", self.x, self.y, checkboxSize, checkboxSize)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(name, self.x + checkboxSize + Font12:getWidth(name) / 8, self.y + checkboxSize / 8)
end

function checkbox:isChecked() return self.value end
