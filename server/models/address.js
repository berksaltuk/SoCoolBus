const mongoose = require("mongoose");

const AddressSchema = new mongoose.Schema({
  address: {
    type: String,
    required: true,
  },
  addressDirections: {
    type: String,
  },
  lat: {
    type: Number,
  },
  lon: {
    type: Number,
  },
  link: {
    type: String,
  },
  // detailed address, we should integrate this into our functions
  il: {
    type: String,
  },
  ilce: {
    type: String,
  },
  mahalle: {
    type: String,
  },
  sokak: {
    type: String,
  },
  bina: {
    type: String,
  },
  binaNo: {
    type: String,
  },
});

const Address = mongoose.model("Address", AddressSchema);
module.exports = Address;
