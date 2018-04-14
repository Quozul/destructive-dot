require "libraries/quozul-tools"

local checkbox = {}
checkbox.__index = checkbox

function newCheckbox(x, y)
    local c = {}
    c.x = x
    c.y = y

    c.value = false
    c.changed = false

    return setmetatable(c, checkbox)
end

function checkbox:update()
    if click.isNew() and buttonHover(self.x, self.y, checkboxSize, checkboxSize) then
        self.value = not self.value
        self.changed = true
        love.audio.stop(sounds.uiClick)
        love.audio.play(sounds.uiClick)
    else
        self.changed = false
    end
end

function checkbox:draw(name, pos)
    if not self.value then
        love.graphics.rectangle("line", self.x, self.y, checkboxSize, checkboxSize)
    else
        love.graphics.rectangle("fill", self.x, self.y, checkboxSize, checkboxSize)
    end

    love.graphics.setColor(1, 1, 1)
    if pos == "right" then
        love.graphics.print(name, self.x + checkboxSize + 10, self.y + Font12:getHeight(name) / (checkboxSize / 3))
    elseif pos == "left" then
        love.graphics.print(name, self.x - Font12:getWidth(name) - 10, self.y + Font12:getHeight(name) / (checkboxSize / 3))
    end
end

function checkbox:isChecked() return self.value end

function checkbox:asChanged() return self.changed end

function checkbox:checkValue(value)
    if value then
        self.value = true
    else
        self.value = false
    end
end
