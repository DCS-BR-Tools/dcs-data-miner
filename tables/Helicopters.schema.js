const { zLuaArray, zLuaObject } = require("../schemas");

module.exports = zLuaArray(
  zLuaObject({ 
    Categories: zLuaArray(),
    AddPropAircraft: zLuaArray(),
    payloadPresets: zLuaArray(zLuaObject({tasks: zLuaArray(), pylons: zLuaArray() })),
    tasks: zLuaArray(),
    paintSchemes: zLuaObject(),
    panelRadio: zLuaArray(zLuaObject({channels: zLuaArray() }))
  }),
);
