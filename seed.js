const Aigle = require("aigle");
const { MongoClient } = require("mongodb");
const { glob } = require("glob");
const { basename, extname } = require("path");
const axios = require("axios");
const { readFileSync, pathExists } = require("fs-extra");
const { resolve } = require("path");
const { DB_NAME, MONGO_URL, ENVS, FILES, VIEWS } = require("./config");
const arg = require("arg");

const args = arg({
  "--only": String,
  '--help': Boolean,
  '-h': '--help',
});
if (args["--help"]) {
  console.log(`Usage: node seed.js [options]
Options:
  --only <option>   Specify what to seed, options are: collections, operators, views
  -h, --help        Show this help message`);
  process.exit(0);
}

const only = args["--only"];

const debug = require("debug")("me_db:seed");

const mongo = new MongoClient(MONGO_URL);
const meDb = mongo.db(DB_NAME);

const sign = (obj, dcsVersion) => {
  obj["@created"] = new Date().toISOString();
  obj["@dcsversion"] = dcsVersion;
  return obj;
};

const populateCollection =
  (dcsVersion) =>
  async ({ name, data, keyFields }) => {
    console.log(`Adding ${name} to DB`);
    const collection = await meDb.collection(name);
    let modifiedCount = 0;
    let upsertedCount = 0;
    await Aigle.eachSeries(data, async (value, _) => {
      try {
        const signed = sign(value, dcsVersion);
        const filter = keyFields.reduce(
          (a, v) => ({ ...a, [v]: signed[v] }),
          {}
        ); //Can add in DCS version here if we want to support multiple versions in the future.
        // use upsert to avoid duplication when running more than once (Eg more than one theater)
        const response = await collection.updateOne(
          filter,
          { $set: signed },
          { upsert: true }
        ); // TODO: Use Bulk Insert
        modifiedCount += response.modifiedCount;
        upsertedCount += response.upsertedCount;
      } catch (e) {
        console.warn(e.message);
      }
    });
    if (data)
      console.log(
        `Upsert Result - Name: ${name}, Total: ${data.length}, Mod: ${modifiedCount}, Upserted: ${upsertedCount}`
      );
  };

async function run() {
  console.log("Validating Mongo Connection");
  await mongo.connect();
  console.log("Mongo Connection OK");

  console.log("Validating DCS Connection");
  await Promise.all(
    Object.keys(ENVS).map(async (key) => {
      const dcsVersion = await axios
        .get(`${ENVS[key]}health`)
        .then((it) => it.data.result);
      return dcsVersion;
    })
  );

  const dcsVersion = await axios
    .post(
      `rpc`,
      {
        jsonrpc: "2.0",
        method: "ping",
        params: ["return _APP_VERSION", "default"],
        id: "1",
      },
      {
        baseURL: ENVS.GUI,
        params: { env: "default" },
        maxContentLength: Infinity,
      }
    )
    .then((it) => it.data.result);
  console.log("DCS Connection OK");

  console.log("Extracting information from DCS");
  const collections = await Aigle.mapSeries(
    await glob(FILES),
    async (_path) => {
      console.log(`Processing ${_path}`);
      const exportScript = readFileSync(_path, "utf-8");
      const [_, target, env, keyFieldsStr] = exportScript.match(
        /^.*?(GUI|MISSION):(\w*):?(\w*,?\w*)/
      );
      const keyFields = keyFieldsStr.split(",");
      const name = basename(_path).replace(extname(_path), "");
      const baseURL = ENVS[target];
      let response = await axios
        .post(
          `rpc`,
          {
            jsonrpc: "2.0",
            method: "ping",
            params: [exportScript, env],
            id: "1",
          },
          {
            baseURL,
            params: { env },
            maxContentLength: Infinity,
          }
        )
        .catch((e) => {
          if (e.code === "ECONNREFUSED") {
            console.info(
              `Failed to connect to the target environment ${target}:${env} while processing ${_path}, please investigate further using DCS Fiddle`
            );
          } else {
            console.error(e);
          }
        });
      if (response.data && response.data.error) {
        console.error(data.error.message, data.error.data);
        data = undefined;
      }
      let data = response.data.result;
      const schemaModulePath = resolve(_path.replace(".lua", ".schema.js"));
      if (await pathExists(schemaModulePath)) {
        const schema = require(schemaModulePath);
        data = schema.cast(data);
      }
      return { name, data, keyFields };
    }
  );

  if (!only || only === "collections") {
    console.log("Populating Mission Editor DB");
    await Aigle.eachSeries(collections, populateCollection(dcsVersion));
    console.log("Populated Mission Editor DB");
  }

  if (!only && only === "operators") {
    console.log("Populating Custom File Tables");
    await Aigle.eachSeries(
      [
        {
          name: "UnitOperators",
          data: require("./customDataSets/UnitOperators.json"),
          keyFields: ["type"],
        },
        {
          name: "UnitOperators",
          data: require("./customDataSets/UnitOperatorsMods.json"),
          keyFields: ["type"],
        },
        {
          name: "Templates",
          data: require("./customDataSets/TemplatesCustom.json"),
          keyFields: ["name", "country"],
        },
      ],
      populateCollection("N/A")
    );
    console.log("Populated Custom File Tables");
  }

  if (only === "views") {
    console.log("Creating Views");
    await Aigle.eachSeries(await glob(VIEWS), async (_path) => {
      const { pipeline, collection, name } = require(resolve(_path));
      console.log(`Adding View ${name}`);
      await meDb
        .command({ collMod: name, viewOn: collection, pipeline })
        .catch(async (e) => {
          console.error(`Failed to update view ${name} due to ${e.message}`);
          await meDb
            .command({ create: name, viewOn: collection, pipeline })
            .catch((e) =>
              console.error(`Failed to create view ${name} due to ${e.message}`)
            );
        });
    });
    console.log("Created Views");
  }

  await mongo.close();
}

run();
