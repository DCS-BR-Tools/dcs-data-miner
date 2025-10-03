--- GUI:default:type
local loadoutUtils = require('me_loadoututils')
me_loadoututils.initBriefingRoomPayloads(nil,nil,nil)
local units = me_db_api.db.Units.Planes.Plane
local _list = {}
for k, v in pairs(units) do
    local _data = {}
    local _type = v.type
    if v[1] == nil then
        _data = v
    else
        for k2,v2 in pairs(v) do
            if k2 ~= 1 then
                _data[k2] = v2
            end
        end
    end
    local schemes = {}
    local callsigns = {}
    for ck, cv in pairs(me_db.db.Countries) do -- This is slow need to find a way to only iterate though countries that are actually used
        local sub_scheme = {}
        local liveriesData = DCS.getObjectLiveriesNames(string.gsub(_type, '/', '_'), cv.ShortName,
        string.lower(require('i18n').getLocale()))

        if liveriesData and not (next(liveriesData) == nil)  then
            for lk, lv in ipairs(liveriesData) do
                table.insert(sub_scheme, lv)
            end
            schemes[tostring(cv.WorldID)] = sub_scheme
        end
        callsigns[tostring(cv.WorldID)] = me_db_api.db.getCallnames(cv.WorldID, _type) or	me_db_api.db.getUnitCallnames(cv.WorldID, me_db_api.unit_by_type[_type].attribute)
    end
    _data['paintSchemes'] = schemes
    _data['callsigns'] = callsigns
    _data['payloadPresets'] = me_loadoututils.getUnitPayloads(_type)
    table.insert(_list, _data)
end

return _list