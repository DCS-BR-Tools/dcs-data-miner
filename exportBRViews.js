const { MongoClient } = require("mongodb");
const { DB_NAME, MONGO_URL, ENVS, FILES, VIEWS } = require("./config");
const mongo = new MongoClient(MONGO_URL);
const meDb = mongo.db(DB_NAME);
const fs = require('fs');
const path = require('path');

const extractMap = {
    'BR_units_cars': 'UnitCars',
    'BR_units_planes': 'UnitPlanes',
    'BR_units_helicopters': 'UnitHelicopters',
    'BR_units_ships': 'UnitShips',
    'BR_units_static_Fortifications': 'UnitFortifications',
    'BR_units_static_Warehouses': 'UnitWarehouses',
    'BR_units_cargo': 'UnitCargo',
    'BR_units_static_Heliports': 'UnitHeliports',
    'Templates': 'Templates',
    'BR_layouts': 'Layouts',
    'BR_airbases': 'TheatersAirbases'
}

const extractMods = {
    'BR_units_cars_mod': 'UnitCars',
    'BR_units_planes_mod': 'UnitPlanes',
    'BR_units_ships_mod': 'UnitShips',
    'BR_units_helicopters_mod': 'UnitHelicopters',
    'BR_units_cargo_mod': 'UnitCargo',
}

async function run() {
    await mongo.connect();
    for (const [key, value] of Object.entries(extractMap)) {
        console.log(key, value)
        const cursor = meDb.collection(key).find()
        const data = await cursor.toArray()
        fs.writeFileSync(`./exports/${value}.json`, JSON.stringify(data, null, 4))
    }

    for (const [key, value] of Object.entries(extractMods)) {
        console.log(key, value)
        const cursor = meDb.collection(key).find()
        const data = await cursor.toArray()
        const modMap = {};
        data.forEach(x => {
            if(!(x.module in modMap))
            {
                modMap[x.module] = []
            }
            modMap[x.module].push(x)
        })
        for (const [mod_key, mod_value] of Object.entries(modMap)) {
            var filePath = `./exports/Mods/${mod_key}/${value}.json`
            var dirPath = path.dirname(filePath);
            fs.mkdirSync(dirPath, { recursive: true })
            fs.writeFileSync(filePath, JSON.stringify(mod_value, null, 4))
        }
    }
    await mongo.close();
}

run();
