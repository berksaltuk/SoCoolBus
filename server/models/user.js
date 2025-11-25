const mongoose = require("mongoose");

const UserSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  password: {
    type: String,
    required: true,
  },
  email: {
    type: String,
  },
  phone: {
    type: String,
    required: true,
    unique: true,
  },
  role: {
    type: String,
    enum: [
      "PARENT",
      "DRIVER",
      "SCHOOL_ADMINISTRATOR",
      "COMPANY_ADMIN",
      "STEWARDESS",
      "ADMIN",
      "SECOND_DRIVER",
    ],
  },
  canHaveRoles: {
    type: [String],
    enum: [
      "PARENT",
      "DRIVER",
      "SCHOOL_ADMINISTRATOR",
      "COMPANY_ADMIN",
      "STEWARDESS",
      "ADMIN",
      "SECOND_DRIVER",
    ],
    //required: true,
  },
  forgetPasswordCode: {
    type: String,
  },
  isForgetPasswordCodeUsed: {
    type: Boolean,
  },
});

const ParentSchema = mongoose.Schema({
  phone: {
    type: String,
    required: true,
    unique: true,
  },
  children: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Student",
    },
  ],
  schools: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "School",
    },
  ],
  address: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Address",
  },
  buses: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "SchoolBus",
    },
  ],
});

const DriverSchema = mongoose.Schema({
  phone: {
    type: String,
    required: true,
    unique: true,
  },
  tcno: {
    type: Number,
    unique: true,
  },
  city: {
    type: String,
  },
  schools: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "School",
    },
  ],
  bus: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "SchoolBus",
  },
  documents: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Document",
    },
  ],
});
const SchoolAdministratorSchema = mongoose.Schema({
  phone: {
    type: String,
    required: true,
    unique: true,
  },
  title: {
    type: String,
  },
  school: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "School",
    required: true,
  },
  isApproved: {
    type: Boolean,
    default: false,
  },
});

const CompanyAdminSchema = mongoose.Schema({
  phone: {
    type: String,
    required: true,
    unique: true,
  },
  title: {
    type: String,
  },
  companyToken: {
    type: String,
    required: true,
  },
  isApproved: {
    type: Boolean,
    default: false,
  },
});

const SecondaryUserSchema = mongoose.Schema({
  phone: {
    type: String,
    required: true,
    unique: true,
  },
  tcno: {
    type: Number,
    unique: true,
  },
  setOfAccess: {
    type: String,
    enum: [
      "FINANCE_ACCESS",
      "ADD_STUDENT_ACCESS",
      "DELETE_STUDENT_ACCESS",
      "ADD_SCHOOL_ACCESS",
      "DELETE_SCHOOL_ACCESS",
      "ADD_ROUTE_ACCESS",
      "SUBSCRIPTION_OP_ACCESS",
      "ADD_EDIT_BANK_ACCOUNT_ACCESS",
      "ADD_SECONDARY_USER_ACCESS",
      "AGENDA_ACCESS",
      "REPORT_ACCESS",
      "EDIT_PROFILE_ACCESS",
      "ACCOUNT_INFO_ACCESS",
    ],
  },
  worksWith: {
    // the driver who added this stewardess.
    type: mongoose.Schema.Types.ObjectId,
    ref: "Driver",
  },
});

const AdminSchema = mongoose.Schema({
  username: {
    type: String,
    required: true,
    unique: true,
  },
  password: {
    type: String,
    required: true,
  },
});

const User = mongoose.model("User", UserSchema);
const Parent = mongoose.model("Parent", ParentSchema);
const Driver = mongoose.model("Driver", DriverSchema);
const SchoolAdministrator = mongoose.model(
  "SchoolAdministrator",
  SchoolAdministratorSchema
);
const CompanyAdmin = mongoose.model("CompanyAdmin", CompanyAdminSchema);
const SecondaryUser = mongoose.model("SecondaryUser", SecondaryUserSchema);
const Admin = mongoose.model("Admin", AdminSchema);

module.exports = allUsers = {
  User,
  Parent,
  Driver,
  SchoolAdministrator,
  CompanyAdmin,
  SecondaryUser,
  Admin,
};
