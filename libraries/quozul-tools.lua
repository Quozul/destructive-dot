local socket = require "socket"

function segmentLengh(x1, y1, x2, y2) return math.sqrt( (x2 - x1)^2 + (y2 - y1)^2 ) end
function segmentDraw(x1, y1, x2, y2) love.graphics.line(x1, y1, x2, y2) end

-- Useful things
function CheckCollision(x1 ,y1 ,w1 ,h1 ,x2 ,y2 ,w2 ,h2) return x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1 end
function sleep(sec) socket.select(nil, nil, sec) end

-- Time in millis
function millis() return socket.gettime() * 1000 end

function boolToNumber(b) if b then return 1 else return 0 end end

-- Random chance
function percentage(chance) if love.math.random(0, 100) <= chance then return true end end

-- Colors things
function setColorRGB(r, g, b) love.graphics.setColor(r/255, g/255, b/255) end
function setColorRGBa(r, g, b, a) love.graphics.setColor(r/255, g/255, b/255, a/255) end

-- Mouses things
function click() if love.mouse.isDown(1) then return true end end

function buttonHover(x, y, w, h)
    mouse = {}
    mouse.x, mouse.y = love.mouse.getX(), love.mouse.getY()
    if mouse.x >= x and mouse.x <= x+w and mouse.y >= y and mouse.y <= y+h then
        return true
    else
        return false
    end
end

-- Random float number
function randomFloat(min, max, precision)
	local precision = precision or 0
	local num = math.random()
	local range = math.abs(max - min)
	local offset = range * num
	local randomnum = min + offset
	return math.floor(randomnum * math.pow(10, precision) + 0.5) / math.pow(10, precision)
end
