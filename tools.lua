require "socket"
vector = {}
slider = {}
slider.sliders = {}

function vector.lengh(posX1, posY1, posX2, posY2) return math.sqrt( (posX2 - posX1)^2 + (posY2 - posY1)^2 ) end
function vector.draw(posX1, posY1, posX2, posY2) love.graphics.line(posX1, posY1, posX2, posY2) end
function sleep(sec) socket.select(nil, nil, sec) end

function randomFloat(min, max, precision)
	local precision = precision or 0
	local num = math.random()
	local range = math.abs(max - min)
	local offset = range * num
	local randomnum = min + offset
	return math.floor(randomnum * math.pow(10, precision) + 0.5) / math.pow(10, precision)
end

-- Buttons
function click() if love.mouse.isDown(1) then return true else return false end end

function buttonHover(x, y, w, h)
    mouse = {}
    mouse.x, mouse.y = love.mouse.getX(), love.mouse.getY()
    if mouse.x >= x and mouse.x <= x+w and mouse.y >= y and mouse.y <= y+h then
        return true
    else
        return false
    end
end

function slider.add(x, y, size, minValue, maxValue, defaultValue, name, minName, maxName)
    s = {}
    s.x, s.y = x, y
    s.size = size
    s.min, s.max, s.value = minValue, maxValue, defaultValue
    s.name, s.minname, s.maxname = name, minName, maxName
    table.insert(slider.sliders, s)
end

function slider.update()
    for _,i in pairs(slider.sliders) do
        if buttonHover(i.x, i.y - 15, i.size - i.x, 15) and click() then
            i.value = love.mouse.getX() - i.x
        end
    end
end

function slider.draw()
    for _,i in pairs(slider.sliders) do
        local unit = i.size / i.max
        local place = i.x + i.value
        love.graphics.line(i.x, i.y, i.size, i.y)
                                                 -- CURSOR
                                    -- x        y          x         y
        love.graphics.polygon("fill", place - 5, i.y - 15, place + 5, i.y - 15, place + 5, i.y - 5, place, i.y, place - 5, i.y - 5 )

        love.graphics.print(i.value + i.min, i.size, i.y - 40) -- Display value


        love.graphics.print(i.name, i.x, i.y - 40) -- Display name
        love.graphics.print(i.minname, i.x, i.y + 5) -- Display minimum name
        love.graphics.print(i.maxname, i.size, i.y + 5) -- Display maximum name
    end
end
