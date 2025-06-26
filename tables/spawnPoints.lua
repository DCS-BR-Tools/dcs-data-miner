--- MISSION:default:theatre,coords

function isEmptyTable(t)
    return next(t) == nil
end

local theater = env.mission.theatre

local id = 0
local debug = false

local maps = {
    -- Afghanistan = {
    --     x = 100000,
    --     xEnd = -500000,
    --     zStart = 100000,
    --     zEnd = 800000
    -- },
    Caucasus = {
        x = 53000,
        xEnd = -425000,
        zStart = 185000,
        zEnd = 947000
    },
    -- Falklands = {
    --     x = 100000,
    --     xEnd = -500000,
    --     zStart = 100000,
    --     zEnd = 800000
    -- },
    GermanyCW = {
        x = 13000,
        xEnd = -530000,
        zStart = -1028000,
        zEnd = -340000
    },
    -- Iraq = {
    --     x = 100000,
    --     xEnd = -500000,
    --     zStart = 100000,
    --     zEnd = 800000
    -- },
    -- Kola = {
    --     x = 100000,
    --     xEnd = -500000,
    --     zStart = 100000,
    --     zEnd = 800000
    -- },
    MarianaIslands = {
        x = 908693,
        xEnd = -91544,
        zStart = -61329,
        zEnd = 138532
    },
    MarianaIslandsWWII = {
        x = 908693,
        xEnd = -91544,
        zStart = -61329,
        zEnd = 138532
    },
    -- Nevada = {
    --     x = 100000,
    --     xEnd = -500000,
    --     zStart = 100000,
    --     zEnd = 800000
    -- },
    -- Normandy = {
    --     x = 100000,
    --     xEnd = -500000,
    --     zStart = 100000,
    --     zEnd = 800000
    -- },
    -- PersianGulf = {
    --     x = 100000,
    --     xEnd = -500000,
    --     zStart = 100000,
    --     zEnd = 800000
    -- },
    -- SinaiMap = {
    --     x = 100000,
    --     xEnd = -500000,
    --     zStart = 100000,
    --     zEnd = 800000
    -- },
    Syria = {
        x = 301000,
        xEnd = -376000,
        zStart = -424000,
        zEnd = 420000
    },
    -- TheChannel = {
    --     x = 100000,
    --     xEnd = -500000,
    --     zStart = 100000,
    --     zEnd = 800000
    -- },
}
local map = maps[theater]
local z = maps[theater].zStart -- start x
local x = maps[theater].x      -- start z

function markSpot()
    if not debug then return end
    trigger.action.circleToAll(-1, id, { x = x, z = z, y = 0 }, 500, { 1, 0, 0, 1 }, { 1, 0, 0, 0.2 }, 1, true)
    id = id + 1
end

local locs = {}
while x > maps[theater].xEnd do
    markSpot()
    while z < maps[theater].zEnd do
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
                table.insert(locs, { BRtype = BRtype, coords = { z1[L].x, z1[L].y }, theatre = theater })
            end
        end
        z = z + 1000
    end
    markSpot()
    z = maps[theater].zStart
    x = x - 1000
end
markSpot()

return locs
