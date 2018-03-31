require "socket"

vector = {}

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
