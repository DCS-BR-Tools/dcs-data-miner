const { zLuaArray, zLuaObject } = require("../schemas");

module.exports = zLuaArray(
  zLuaObject({
    Categories: zLuaArray(),
    AddPropAircraft: zLuaArray(),
    SpecificCallnames: zLuaObject({USA: zLuaArray()}),
    payloadPresets: zLuaArray(zLuaObject({tasks: zLuaArray(), pylons: zLuaArray() })),
    tasks: zLuaArray(),
    Tasks: zLuaArray(),
    paintSchemes: zLuaObject(),
    panelRadio: zLuaArray(zLuaObject({channels: zLuaArray() }))
  }),
);
