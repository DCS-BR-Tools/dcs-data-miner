const { zLuaArray, zLuaObject } = require("../schemas");

module.exports = zLuaArray(
  zLuaObject({
    paintSchemes: zLuaObject(),
  }),
);
