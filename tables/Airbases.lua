--- MISSION:default:WorldID,theatre


function generalPosObj(DCSpos)
    lat, lon, alt = coord.LOtoLL(DCSpos)
    return {
        ['DCS'] = DCSpos,
        ['World'] = {
            ['lat'] = lat,
            ['lon'] = lon,
            ['alt'] = alt
        }
    }
end


local reverse_category = {}

for k,v in pairs(Airbase.Category) do
    reverse_category[v] = k
end

local airbases = {}

-- TODO: Get this from a correct location
local term_type = {
    [16] = "Runway",
    [40] = "HelicopterOnly",
    [68] = "HardenedAirShelter",
    [72] = "AirplaneOnly",
    [100] = "SmallAirplane",
    [104] = "OpenAirSpawn",
    [176] = "AirplaneOnlyAndOpenAirSpawn",
    [216] = "AllHelicopterUsable",
    [244] = "AllAirplaneUsable",
    [311] = "AllSmallAirplaneUsable",
}

for k,v in pairs(world.getAirbases()) do
    local airbase = {
        ID = v:getID(),
        WorldID = v:getWorldID(),
        callsign = v:getCallsign(),
        typeName = v:getTypeName()
    }

    for _k,_v in pairs(v:getDesc()) do
        airbase[_k] = _v
    end

    airbase["category_name"] = reverse_category[airbase.category]

    airbase["runways"] = {}

    for _k,_v in pairs(v:getRunways()) do
        _v["id"] = _k
        table.insert(airbase["runways"], _v)
    end

    airbase["parking"] = {}

    for _k,_v in pairs(v:getParking()) do
        _v["id"] = _k
        table.insert(airbase["parking"], _v)
    end

    airbase["theatre"] = env.mission.theatre
    airbase["pos"] = generalPosObj(v:getPoint())

    for _k,_v in pairs(airbase.parking) do
        _v.Term_Type_Name = term_type[_v.Term_Type]
        _v.pos = generalPosObj(_v.vTerminalPos)
    end

    table.insert(airbases, airbase)
end

return airbases