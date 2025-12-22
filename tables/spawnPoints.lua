--- MISSION:default:theatre,coords

function isEmptyTable(t)
    return next(t) == nil
end

local theatre = env.mission.theatre

local id = 0
local debug = false
-- IF UPDATING A MAP DELETE ALL THE OLD POINTS IN THE DATABASE
local maps = {
    Afghanistan = { -- Done 03/07/2024
        x = 241264,
        xEnd = -332518,
        zStart = -399961,
        zEnd = 475762
    },
    Caucasus = { -- Done 28/06/2024
        x = 53000,
        xEnd = -425000,
        zStart = 185000,
        zEnd = 947000
    },
    Falklands = { -- Done 04/07/2024
        x = 342234,
        xEnd = -421635,
        zStart = -1403914,
        zEnd = 147806
    },
    GermanyCW = { -- Done 28/06/2024
        x = 185000,
        xEnd = -600000,
        zStart = -1028000,
        zEnd = -320000
    },
    Iraq = { -- Done 03/07/2024
        x = 419110,
        xEnd = -948496,
        zStart = -492867,
        zEnd = 848496
    },
    Kola = { -- Done 03/07/2024
        x = 419696,
        xEnd = -314829,
        zStart = -588360,
        zEnd = 843023
    },
    MarianaIslands = { -- Done 28/06/2024
        x = 908693,
        xEnd = -91544,
        zStart = -61329,
        zEnd = 138532
    },
    MarianaIslandsWWII = { -- Done 28/06/2024
        x = 908693,
        xEnd = -91544,
        zStart = -61329,
        zEnd = 138532
    },
    Nevada = { -- Done 04/07/2024
        x = -91264,
        xEnd = -582440,
        zStart = -367294,
        zEnd = 174013
    },
    Normandy = { -- Done 04/07/2024
        x = 247743,
        xEnd = -124043,
        zStart = -195360,
        zEnd = 253654
    },
    PersianGulf = { -- Done 04/07/2024
        x = 728050,
        xEnd = -286974,
        zStart = -586668,
        zEnd = 332786
    },
    SinaiMap = { -- Done 03/07/2024
        x = 479023,
        xEnd = -498781,
        zStart = -183378,
        zEnd = 558892
    },
    Syria = { -- Done 28/06/2024
        x = 301000,
        xEnd = -376000,
        zStart = -424000,
        zEnd = 420000
    },
    TheChannel = { -- Done 04/07/2024
        x = 70873,
        xEnd = -126974,
        zStart = -114175,
        zEnd = 127616
    },
}
local map = maps[theatre]
local z = maps[theatre].zStart -- start x
local x = maps[theatre].x      -- start z

function markSpot()
    if not debug then return end
    trigger.action.circleToAll(-1, id, { x = x, z = z, y = 0 }, 500, { 1, 0, 0, 1 }, { 1, 0, 0, 0.2 }, 1, true)
    id = id + 1
end

local locs = {}
while x > maps[theatre].xEnd do
    markSpot()
    while z < maps[theatre].zEnd do
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
                table.insert(locs, { BRtype = BRtype, coords = { z1[L].x, z1[L].y }, theatre = theatre })
            end
        end
        z = z + 1000
    end
    markSpot()
    z = maps[theatre].zStart
    x = x - 1000
end
markSpot()

return locs
