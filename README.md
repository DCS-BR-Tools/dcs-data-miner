# Data Miner
Project initially created as part of: https://github.com/JonathanTurnock/dcs-mission-maker

This project spins up a local MongoDB using docker and when `seed.js` is run it will mine DCS for data.

It requires the [Pelican RPC communication mod](https://dcs-dropzone.app/#/pelican) to be installed

NOTE: Some exporters also require a mission to be running (i.e. Terrain), these will fail and notify 
in the console but be aware any conections to the `MISSION` environment WILL fail unless a mission is running.

## _id, @created and @dcsversion

> As exports occur the exported object is hashed, this is the document ID.
> As it gets added to the DB it has a `@created` field.
> 
> Repeat runs will not create duplicate documents, but note if something changes in the data the ID will different 
> and the document will be populated with a newer `@created` field.
> 
> Each object also has an `@dcsversion` field which denotes what DCS version was used for exporting.

## Usage

### MongoDB

MongoDB is a document store, it allows you to `filter` data and also `project` results.

Filtering is the act of writing a query to get a subset of results.

![img.png](img.png)

Projecting is the act of specifying how much of the matched document you want returned.

![img_1.png](img_1.png)

MongoDB also supports Mapping from one table to another to join data.

> TBC IMG

#### Starting

To run MongoDB you will need Docker Installed along with docker-compose.

from the data-miner folder run 

```shell
docker-compose up -d
```

#### Connecting

Install MongoDB Compass and ensure the connection succeeds

By Default the connection string is `mongodb://admin:admin@localhost:27017/`

> https://www.mongodb.com/products/compass

### Seed

To seed the MongoDB from your active DCS instance DCS must be running.

The script will validate the connection to DCS before starting.

Set the current working directory to be the data-miner folder

```shell
cd data-miner 
```

Run the script from the data-miner folder

```shell
node seed.js 
```

extra options can be found by using
```shell
node seed.js --help
```

if you need to create views then use
```shell
node seed.js --only=views
```

Once run the MongoDB will have a new database and tables.