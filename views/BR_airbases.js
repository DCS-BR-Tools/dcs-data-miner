const pipeline = [
  {
    $lookup: {
      from: "Airodromes",
      let: {
        id: "$ID",
        theatre: "$theatre",
      },
      pipeline: [
        {
          $match: {
            $expr: {
              $and: [
                {
                  $eq: ["$airbase_id", "$$id"],
                },
                {
                  $eq: ["$theatre", "$$theatre"],
                },
              ],
            },
          },
        },
      ],
      as: "raw",
    },
  },
  {
    $unwind: {
      path: "$raw",
      preserveNullAndEmptyArrays: true,
    },
  },
  {
    $lookup: {
      from: "Radios",
      let: {
        id: {
          $ifNull: ["$raw.radio", []],
        },
        theatre: "$theatre",
      },
      pipeline: [
        {
          $match: {
            $expr: {
              $and: [
                {
                  $in: ["$radioId", "$$id"],
                },
                {
                  $eq: ["$theatre", "$$theatre"],
                },
              ],
            },
          },
        },
      ],
      as: "radio",
    },
  },
  {
    $lookup: {
      from: "Beacons",
      let: {
        id: {
          $ifNull: ["$raw.beacons.beaconId", []],
        },
        theatre: "$theatre",
      },
      pipeline: [
        {
          $match: {
            $expr: {
              $and: [
                {
                  $in: ["$beaconId", "$$id"],
                },
                {
                  $eq: ["$theatre", "$$theatre"],
                },
              ],
            },
          },
        },
      ],
      as: "beacons",
    },
  },
  {
    $addFields: {
      stands: "$raw.stands",
      code: "$raw.code",
      airdromeData: {
        runways: {
          $map: {
            input: {
              $ifNull: ["$raw.runways", []],
            },
            as: "run",
            in: "$$run.name",
          },
        },
        ATC: {
          $ifNull: ["$radio.frequency", []],
        },
        TACAN: {
          $map: {
            input: {
              $filter: {
                input: "$beacons",
                as: "be",
                cond: {
                  $eq: ["$$be.type_name", "TACAN"],
                },
              },
            },
            as: "be",
            in: "$$be.channel",
          },
        },
        ILS: {
          $map: {
            input: {
              $filter: {
                input: "$beacons",
                as: "be",
                cond: {
                  $eq: ["$$be.type_name", "ILS_GLIDESLOPE"],
                },
              },
            },
            as: "be",
            in: "$$be.frequency",
          },
        },
      },
    },
  },
  {
    $unwind: {
      path: "$airdromeData.ATC",
      preserveNullAndEmptyArrays: true,
    },
  },
  {
    $addFields: {
      airdromeData: {
        ATC: {
          $map: {
            input: {
              $ifNull: ["$airdromeData.ATC", []],
            },
            as: "atc",
            in: {
              $arrayElemAt: ["$$atc", 1],
            },
          },
        },
      },
    },
  },
  {
    $unset: [
      "_id",
      "raw",
      "radio",
      "beacons",
      "attributes",
      "category_name",
      "life",
      "category",
      "WorldID",
      "callsign",
      "_origin",
      "@created",
      "@dcsversion",
    ],
  },
  {
    $sort: {
      theatre: 1,
    },
  },
];

module.exports = {
  pipeline,
  collection: "Airbases",
  name: "BR_airbases",
};
