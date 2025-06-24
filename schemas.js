const { isObject, values, isArray } = require("lodash");
const { array, object } = require("yup");

const zLuaArray = (schema) =>
  array(schema).transform((it) => {
    if (isObject(it)) return values(it);
    return it;
  });

const zLuaObject = (schema) => object(schema).transform((it) => {
  if(isArray(it) && it.length === 0) {
    return {};
  }
  return it;
});

module.exports = { zLuaArray, zLuaObject };
