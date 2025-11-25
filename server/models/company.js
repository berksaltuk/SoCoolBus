const mongoose = require("mongoose");
const crypto = require("crypto");
const CompanySchema = new mongoose.Schema({
  companyName: {
    type: String,
    required: true,
  },
  companyToken: {
    //automatically generated and unique
    type: String,
    unique: true,
    default: crypto.randomUUID,
  },
  city: {
    type: String,
  },
  isApproved: {
    type: Boolean,
    default: false,
  },
  whoAddedCompanyPhone: {
    type: String,
  },
});

module.exports = Company = mongoose.model("Company", CompanySchema);
