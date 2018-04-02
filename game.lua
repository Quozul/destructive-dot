function removeObject()
    for e,i in ipairs(objects.objects) do
        if CheckCollision(ply.x - 10, ply.y - 10, 10, 10, i.x - 10, i.y - 10, objects.w, objects.w) then
            table.remove(objects.objects, e)
            objects.count = objects.count - 1
            love.audio.stop(sounds.object)
            love.audio.play(sounds.object)

            if i.golden == 1 then
                --ply.score = ply.score + round(100 / objects.limit, 1)
                ply.score = ply.score + round(100 / objects.limit * ply.destructionSeries, 1)
                ply.destructionSeries = ply.destructionSeries + 1

                for n=10,love.math.random(minParts, maxParts) do
                    createParticles(true, i.x, i.y)
                end
            else
                for n=10,love.math.random(minParts, maxParts) do
                    createParticles(false, i.x, i.y)
                end
            end
        end
    end

    if ply.xspeed + ply.yspeed <= 0.01 then ply.destructionSeries = 1 end
end

function movements()
    ply.x = ply.x + ply.xspeed
    ply.y = ply.y + ply.yspeed

    ply.xspeed = ply.xspeed / 1.3
    ply.yspeed = ply.yspeed / 1.3

    if ply.x + ply.radius >= game.width - game.border then
        ply.xspeed = -ply.xspeed
        ply.x = game.width - game.border - ply.radius
        hitWall()
    elseif ply.x - ply.radius <= game.border then
        ply.xspeed = -ply.xspeed
        ply.x = game.border + ply.radius
        hitWall()
    end

    if ply.y + ply.radius >= game.height - game.border then
        ply.yspeed = -ply.yspeed
        ply.y = game.height - game.border - ply.radius
        hitWall()
    elseif ply.y - ply.radius <= game.border then
        ply.yspeed = -ply.yspeed
        ply.y = game.border + ply.radius
        hitWall()
    end
end

function hitWall() love.audio.stop(sounds.wall) love.audio.play(sounds.wall) end
