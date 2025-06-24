module.exports = {
  MONGO_URL: "mongodb://admin:admin@127.0.0.1:27017",
  DB_NAME: "me_db",
  //FILES: "./tables/{Airbases,Airodromes,Terrains,Beacons,Radios}.lua", // Run once per theatre
  //FILES: "./tables/{Planes,Cars,Helicopters,Ships,Cargos,Weapons,Fortifications,Templates,ADEquipment,Theatres,Warehouses,Heliports,Layouts}.lua", // Run once per dcs version
  FILES: "./tables/spawnPoints.lua", // Spawn points once per map
  VIEWS: "./views/*.js", // Run once per dcs version
  ENVS: {
    MISSION: "http://127.0.0.1:1235/",
    GUI: "http://127.0.0.1:1234/",
  },
};
