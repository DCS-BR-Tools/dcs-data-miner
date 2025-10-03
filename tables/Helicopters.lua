--- GUI:default:type
local loadoutUtils = require('me_loadoututils')
local units = me_db.db.Units.Helicopters.Helicopter
me_loadoututils.initBriefingRoomPayloads(nil,nil,nil)
local _list = {}
for k, v in pairs(units) do
    local schemes = {}
    local callsigns = {}
    for ck, cv in pairs(me_db.db.Countries) do -- This is slow need to find a way to only iterate though countries that are actually used
        local sub_scheme = {}
        local liveriesData = DCS.getObjectLiveriesNames(string.gsub(v.type, '/', '_'), cv.ShortName,
        string.lower(require('i18n').getLocale()))

        if liveriesData and not (next(liveriesData) == nil)  then
            for k, v in ipairs(liveriesData) do
                table.insert(sub_scheme, v)
            end
            schemes[tostring(cv.WorldID)] = sub_scheme
        end
        callsigns[tostring(cv.WorldID)] = me_db_api.db.getCallnames(cv.WorldID, v.type) or	me_db_api.db.getUnitCallnames(cv.WorldID, me_db_api.unit_by_type[v.type].attribute)
    end
    v['paintSchemes'] = schemes
    v['callsigns'] = callsigns
    v['payloadPresets'] = me_loadoututils.getUnitPayloads(v.type)
    table.insert(_list, v)
end

return _list
