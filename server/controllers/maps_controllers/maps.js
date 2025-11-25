const { Client } = require("@googlemaps/google-maps-services-js");
require("dotenv").config();

const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

module.exports.reverseGeocoding = async (req, res) => {
  let { lat, lng } = req.body;
  const client = new Client({});

  latLngString = lat + "," + lng;
  client
    .reverseGeocode({
      params: {
        latlng: latLngString,
        key: process.env.GOOGLE_MAPS_API_KEY,
        location_type: "APPROXIMATE",
      },
      timeout: 1000, // milliseconds
    })
    .then((r) => {
      return res.status(200).send({ result: r.data.results[0] });
    })
    .catch((e) => {
      logtail.error(e.response.data.error_message);
      logtail.flush();
      return res.status(500).send(e.response.data.error_message);
    });
};

module.exports.geocoding = async (req, res) => {
  let { address } = req.body;
  const client = new Client({});

  client
    .geocode({
      params: {
        address: address,
        key: process.env.GOOGLE_MAPS_API_KEY,
      },
      timeout: 1000, // milliseconds
    })
    .then((r) => {
      return res
        .status(200)
        .send({ result: r.data.results[0].geometry.location });
    })
    .catch((e) => {
      logtail.error(e.response.data.error_message);
      logtail.flush();
      return res.status(500).send(e.response.data.error_message);
    });
};

module.exports.calculateDistance = async (req, res) => {
  let { driverLocation, studentAndLocations } = req.body;
  const client = new Client({});

  client
    .distancematrix({
      params: {
        mode: "driving",
        origins: [driverLocation],
        destinations: studentAndLocations.map((el) => {
          return el.location;
        }),
        key: process.env.GOOGLE_MAPS_API_KEY,
      },
      timeout: 1000, // milliseconds
    })
    .then((r) => {
      if (r.data.rows[0].elements.find((e) => e.status === "ZERO_RESULTS")) {
        return res
          .status(400)
          .send({ msg: "Some of the location information are incorrect." });
      }
      console.log(r.data.rows[0].elements);
      let distances = r.data.rows[0].elements.map((el) => {
        return el.distance.value;
      });

      let studentsAndDistances = [];

      for (let i = 0; i < studentAndLocations.length; i++) {
        studentsAndDistances.push({
          studentID: studentAndLocations[i].studentID,
          distance: distances[i],
        });
      }

      const sorted = studentsAndDistances.sort(
        (firstItem, secondItem) => firstItem.distance - secondItem.distance
      );

      return res.status(200).send({
        result: sorted,
      });
    })
    .catch((e) => {
      logtail.error(e);
      logtail.flush();
      return res.status(500).send(e);
    });
};

module.exports.calculateDistanceFunc = async (
  driverLocation,
  studentAndLocations
) => {
  try {
    const client = new Client({});

    const r = client.distancematrix({
      params: {
        mode: "driving",
        origins: [driverLocation],
        destinations: studentAndLocations.map((el) => {
          return el.location;
        }),
        key: process.env.GOOGLE_MAPS_API_KEY,
      },
      timeout: 1000, // milliseconds
    });

    if (r.data.rows[0].elements.find((e) => e.status === "ZERO_RESULTS")) {
      return res
        .status(400)
        .send({ msg: "Some of the location information are incorrect." });
    }
    let distances = r.data.rows[0].elements.map((el) => {
      return el.distance.value;
    });

    let studentsAndDistances = [];

    for (let i = 0; i < studentAndLocations.length; i++) {
      studentsAndDistances.push({
        studentID: studentAndLocations[i].studentID,
        distance: distances[i],
      });
    }

    const sorted = studentsAndDistances.sort(
      (firstItem, secondItem) => firstItem.distance - secondItem.distance
    );

    return res.status(200).send({
      result: sorted,
    });
  } catch (e) {
    logtail.error(e.response.data.error_message);
    logtail.flush();
    return res.status(500).send(e);
  }
};

module.exports.geocodingFunc = async (addr) => {
  try {
    const client = new Client({});

    const r = await client.geocode({
      params: {
        address: addr,
        key: process.env.GOOGLE_MAPS_API_KEY,
      },
      timeout: 1000, // milliseconds
    });

    return r.data.results[0].geometry.location;
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    console.error("Maps.ERROR: " + error.message);
    return null;
  }
};

module.exports.calculateRouteFunc = async (parentID) => {
  try {
    const client = new Client({});

    return null;
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    console.error(error.message);
    return null;
  }
};
