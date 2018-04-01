function removeObject()
    for e,i in ipairs(objects.objects) do
        if CheckCollision(ply.x - 10, ply.y - 10, 10, 10, i.x - 10, i.y - 10, objects.w, objects.w) then
            table.remove(objects.objects, e)
            objects.count = objects.count - 1
            love.audio.stop(sounds.object)
            love.audio.play(sounds.object)

            if i.golden == 1 then
                ply.score = ply.score + 1

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
end

function movements()
    ply.x = ply.x + ply.xspeed
    ply.y = ply.y + ply.yspeed

    ply.xspeed = ply.xspeed / 1.3
    ply.yspeed = ply.yspeed / 1.3

    if ply.x >= game.width - game.border then
        ply.xspeed = -ply.xspeed
        ply.x = game.width - game.border
        hitWall()
    elseif ply.x <= game.border then
        ply.xspeed = -ply.xspeed
        ply.x = game.border
        hitWall()
    end

    if ply.y >= game.height - game.border then
        ply.yspeed = -ply.yspeed
        ply.y = game.height - game.border
        hitWall()
    elseif ply.y <= game.border then
        ply.yspeed = -ply.yspeed
        ply.y = game.border
        hitWall()
    end
end

function hitWall() love.audio.stop(sounds.wall) love.audio.play(sounds.wall) end
