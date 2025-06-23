function isEmptyTable(t)
    return next(t) == nil
end

local id = 0
local debug = false

-- Caucasus
-- local x = 53000
-- local xEnd = -425000
-- local zStart = 185000
-- local zEnd = 947000


-- CW Germany
-- local x = 13000
-- local xEnd = -530000
-- local zStart = -1028000
-- local zEnd = -340000

-- Syria
-- local x = 301000
-- local xEnd = -376000
-- local zStart = -424000
-- local zEnd = 420000

local z = zStart -- start x

function markSpot()
    if not debug then return end
    trigger.action.circleToAll(-1, id, { x = x, z = z, y = 0 }, 500, { 1, 0, 0, 1 }, { 1, 0, 0, 0.2 }, 1, true)
    id = id + 1
end

local locs = {}
while x > xEnd do
    markSpot()
    while z < zEnd do
        local coords = { x = x, z = z, y = 0 }
        if not debug and not Disposition.getPointWater(coords, 215, 1) then
            local BRtype = "LandLarge"
            local z1 = Disposition.getSimpleZones(coords, 500, 215, 1, false)
            if isEmptyTable(z1) then
                BRtype = "LandMedium"
                z1 = Disposition.getSimpleZones(coords, 500, 100, 1, false)
            end
            if isEmptyTable(z1) then
                BRtype = "LandSmall"
                z1 = Disposition.getSimpleZones(coords, 500, 10, 1, false)
            end
            for L = 1, #z1 do
                table.insert(locs, { BRtype = BRtype, coords = { z1[L].x, z1[L].y } })
            end
        end
        z = z + 1000
    end
    markSpot()
    z = zStart
    x = x - 1000
end
markSpot()

return locs
