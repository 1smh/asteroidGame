-- by Rikhil and Jason
-- ship == satellite we're just too lazy

-- global vars
winWidth = 800
winLen = 600
shipSize = 30
asteroidSize = 112
asteroidRadius = 150
laserDelay = 0.1
laserSpeed = 20

-- circle pos
function love.load()

    -- ships
    shipX = 800 / 2
    shipY = 600 / 2
    shipAngle = 0
    horizontalSpeed = 0
    verticalSpeed = 0

    -- electromagnetic high frequency pulse waves
    lasers = {}

    -- asteroids 
    -- TODO: RANDOMIZE/ALGORITHMITIZE THE ASTEROIDS
    asteroids = {
        {x = 80, y = 80, stage = 1, directionHorizontal = 1, directionVertical = 1}, 
        {x = winWidth - 80, y = 100, stage = 1, directionHorizontal = 1, directionVertical = 1}, 
        {x = winWidth / 2, y = winLen - 100, stage = 1, directionHorizontal = 1, directionVertical = 1}
    }
    
    -- random asteroid angle in rad
    for temp, asteroid in ipairs(asteroids) do
        asteroid.angle = love.math.random() * (2 * math.pi)
    end

    -- import asteroid file
    myImage = love.graphics.newImage("asteroid.png")
    myImage2 = love.graphics.newImage("ship.png")
end

function love.update(dt)
    -- ship mechanics + normalization 
    if love.keyboard.isDown('d') then horizontalSpeed = horizontalSpeed + 10 end
    if love.keyboard.isDown('a') then horizontalSpeed = horizontalSpeed - 10 end
    if love.keyboard.isDown('w') then verticalSpeed = verticalSpeed - 10 end
    if love.keyboard.isDown('s') then verticalSpeed = verticalSpeed + 10 end

    shipX = shipX + horizontalSpeed * dt
    shipY = shipY + verticalSpeed * dt

    -- if shipX >= winWidth - shipSize - 10 then horizontalSpeed = -10 end
    -- if shipX <= shipSize + 10 then horizontalSpeed = 10 end
    -- if shipY >= winLen - shipSize - 10 then verticalSpeed = -10 end
    -- if shipY <= shipSize + 10 then verticalSpeed = 10 end

    if shipX <= -100 then horizontalSpeed = 10 end
    if shipY <= -60 then verticalSpeed = 10 end
    if shipX >= winWidth - shipSize - 200 then horizontalSpeed = -10 end
    if shipY >= winLen - shipSize - 100 then verticalSpeed = -10 end
        
    
    -- laser mechanics
    local mouseX, mouseY = love.mouse.getPosition()
    shipAngle = math.atan2(mouseY - (shipY + 90), mouseX - (shipX + 90))

    laserDelay = laserDelay - dt
    if love.mouse.isDown("1") then
        -- let's pretend like it never overflows 
        if laserDelay <= 0 then  
            -- table.insert(lasers, {x = shipX + math.cos(shipAngle) * shipSize, y = shipY + math.sin(shipAngle) * shipSize, z = shipAngle})
            table.insert(lasers, {x = shipX + 90, y = shipY + 90, z = shipAngle})
            laserDelay = 0.25
        end
    end

    local function areCirclesIntersecting(aX, aY, aRadius, bX, bY, bRadius)
        return (aX - bX)^2 + (aY - bY)^2 <= (aRadius + bRadius)^2
    end

    -- moving asteroids
    for asteroidIndex, asteroid in ipairs(asteroids) do
        local asteroidSpeed = 50
        asteroid.x = asteroid.x + math.cos(asteroid.angle) * asteroidSpeed * dt * asteroid.directionHorizontal
        asteroid.y = asteroid.y + math.sin(asteroid.angle) * asteroidSpeed * dt * asteroid.directionVertical
        
        -- Check if asteroid hit the borders
        if asteroid.x > winWidth - asteroidSize then 
            asteroid.directionHorizontal = -1 
            asteroid.x = winWidth - asteroidSize
        end
        if asteroid.x < 0 then 
            asteroid.directionHorizontal = 1 
            asteroid.x = 0
        end
        if asteroid.y > winLen - asteroidSize then 
            asteroid.directionVertical = -1 
            asteroid.y = winLen - asteroidSize
        end
        if asteroid.y <= 0 then 
            asteroid.directionVertical = 1 
            asteroid.y = 0
        end

        -- working collision detector 
        -- if areCirclesIntersecting(asteroid.x + 112.5, asteroid.y + 112.5, asteroidSize/1.5, shipX, shipY, shipSize) then
        --     love.event.quit()
        -- end
    end

    if #asteroids == 0 then love.event.quit() end 
end

function love.draw()

    local function areCirclesIntersecting(aX, aY, aRadius, bX, bY, bRadius)
        return (aX - bX)^2 + (aY - bY)^2 <= (aRadius + bRadius)^2
    end

    -- drawing spaceship
    love.graphics.setColor(1, 1, 1)
    love.graphics.push()
    love.graphics.translate(shipX + 90 + myImage2:getWidth() * 0.05, shipY + myImage2:getHeight() * 0.05) -- Adjust the translation
    love.graphics.rotate(shipAngle)
    love.graphics.draw(myImage2, -myImage2:getWidth() * 0.05, -myImage2:getHeight() * 0.05, 0, 0.1, 0.1)
    love.graphics.pop()

    -- drawing lasers
    for lasterIndex, laser in ipairs(lasers) do
        love.graphics.setColor(1, 0, 0)
        love.graphics.push()
        love.graphics.translate(laser.x, laser.y)
        love.graphics.rotate(laser.z + math.pi/2)
        love.graphics.rectangle('fill', 0, 0, 5, 15)
        love.graphics.pop()
        laser.x = laser.x + laserSpeed * math.cos(laser.z)
        laser.y = laser.y + laserSpeed * math.sin(laser.z)

        for asteroidIndex, asteroid in ipairs(asteroids) do
            if areCirclesIntersecting(laser.x, laser.y, 0, asteroid.x + 112.5, asteroid.y + 112.5, asteroidSize) then
                table.remove(lasers, lasterIndex)

                local canSplit = false
                if asteroid.stage == 1 then canSplit = true end

                local angle1 = love.math.random() * (2 * math.pi)
                local angle2 = (angle1 - math.pi) % (2 * math.pi)

                if canSplit then 
                    table.insert(asteroids, {
                        x = asteroid.x,
                        y = asteroid.y,
                        angle = angle1,
                        stage = 0,
                        directionHorizontal = 1,
                        directionVertical = 1
                    })
                    table.insert(asteroids, {
                        x = asteroid.x,
                        y = asteroid.y,
                        angle = angle2,
                        stage = 0,
                        directionHorizontal = 1,
                        directionVertical = 1
                    })
                end

                table.remove(asteroids, asteroidIndex)

                break
            end
        end
    end

    -- drawing asteroids
    for temp, asteroid in ipairs(asteroids) do
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(myImage, asteroid.x, asteroid.y - 50, 0, 0.5*(0.5)^(2 - asteroid.stage), 0.5*(0.5)^(2 - asteroid.stage))

    end
end



