require "socket"
vector = {}
slider = {}
slider.sliders = {}

function vector.lengh(posX1, posY1, posX2, posY2) return math.sqrt( (posX2 - posX1)^2 + (posY2 - posY1)^2 ) end
function vector.draw(posX1, posY1, posX2, posY2) love.graphics.line(posX1, posY1, posX2, posY2) end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

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

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function setColorRGB(r, g, b) -- This is used to keep 255 values from Love 0.10.2
    love.graphics.setColor(r/255, g/255, b/255)
end
