const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const { Admin } = require("../../models/user");
const Document = require("../../models/document");
const School = require("../../models/school");
const Company = require("../../models/company");
const {
  CompanyAdmin,
  User,
  SchoolAdministrator,
} = require("../../models/user");
const { sendCustomMessage } = require("../sms_controllers/sms");

const {
  S3Client,
  PutObjectCommand,
  GetObjectCommand,
  DeleteObjectCommand,
} = require("@aws-sdk/client-s3");

const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");

const bucketName = process.env.AWS_BUCKET_NAME;
const bucketRegion = process.env.AWS_BUCKET_REGION;
const accessKey = process.env.AWS_ACCESS_KEY;
const secretAccessKey = process.env.AWS_SECRET_ACCESS_KEY;

const s3 = new S3Client({
  credentials: {
    accessKeyId: accessKey,
    secretAccessKey: secretAccessKey,
  },
  region: bucketRegion,
});
module.exports.approveOrRejectSchool = async (req, res) => {
  try {
    const { approve, schoolID } = req.body;
    let school = await School.findById(schoolID);

    if (approve) {
      school.isApproved = true;
      await school.save();
      sendCustomMessage(
        school.whoAddedSchoolPhone,
        "Okul ekleme talebiniz onaylanmıştır. Okulu çalıştığınız okullara ekleyebilirsiniz. Okul adı: " +
          school.name
      );
    } else {
      await school.remove();
      sendCustomMessage(
        school.whoAddedSchoolPhone,
        "Okul ekleme talebiniz reddedilmiştir. Bilgilerin doğruluğunu teyit edip tekrar deneyebilirsiniz. Okul adı: " +
          school.name
      );
    }

    return res.status(200).json({
      msg:
        "Approval operation is successfully completed for school with ID " +
        schoolID,
    });
  } catch (error) {
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getUnapprovedSchools = async (req, res) => {
  try {
    let schools = await School.find({ isApproved: false });
    return res.status(200).json(schools);
  } catch (error) {
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.approveOrRejectDocument = async (req, res) => {
  try {
    const { approve, documentID } = req.body;

    let document = await Document.findById(documentID);
    if (approve) {
      document.isApproved = true;
    } else {
      document.isRejected = true;
      sendCustomMessage(
        document.driverPhone,
        "Yüklediğiniz doküman reddedilmiştir. Bilgilerin doğruluğunu teyit edip tekrar deneyebilirsiniz. Doküman adı: " +
          document.fileName
      );
    }

    await document.save();

    return res.status(200).json({
      msg:
        "Approval operation is successfully completed for document with ID " +
        documentID,
    });
  } catch (error) {
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getUnapprovedDocuments = async (req, res) => {
  try {
    let documents = await Document.find({ isApproved: false });

    let result = await Promise.all(
      documents.map(async (doc) => {
        const getObjectParams = {
          Bucket: bucketName,
          Key: doc.fileName,
        };
        const command = new GetObjectCommand(getObjectParams);

        const url = await getSignedUrl(s3, command, { expiresIn: 3600 });
        return {
          _id: doc._id,
          documentName: doc.documentName,
          driverPhone: doc.driverPhone,
          documentType: doc.documentType,
          fileURL: url,
        };
      })
    );

    return res.status(200).json(result);
  } catch (error) {
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.approveOrRejectCompanyAdmin = async (req, res) => {
  try {
    const { approve, companyAdminPhone } = req.body;
    let companyAdmin = await CompanyAdmin.findOne({ phone: companyAdminPhone });
    let user = await User.findOne({ phone: companyAdminPhone });

    if (approve) {
      companyAdmin.isApproved = true;
      await companyAdmin.save();

      sendCustomMessage(
        companyAdminPhone,
        "İdari şoför hesabınız onaylanmıştır. Belirlediğiniz şifre ile sisteme giriş yapabilirsiniz."
      );
    } else {
      if (user.canHaveRoles.length > 1) {
        const index = user.canHaveRoles.indexOf("COMPANY_ADMIN");
        user.canHaveRoles.splice(index, 1); //2nd parameter means remove one item only
        if (user.role == "COMPANY_ADMIN") {
          user.role = user.canHaveRoles[0];
        }
        await user.save();
      } else {
        await user.remove();
      }
      await companyAdmin.remove();

      sendCustomMessage(
        companyAdminPhone,
        "İdari şoför hesabı oluşturma isteğiniz reddedilmiştir."
      );
    }

    return res.status(200).json({
      msg:
        "Approval operation is successfully completed for company admin with phone " +
        companyAdminPhone,
    });
  } catch (error) {
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getUnapprovedCompanyAdmins = async (req, res) => {
  try {
    const results = await CompanyAdmin.aggregate([
      {
        $match: {
          isApproved: false,
        },
      },
      {
        $lookup: {
          from: "companies",
          localField: "companyToken",
          foreignField: "companyToken",
          pipeline: [
            {
              $match: {
                isApproved: true,
              },
            },
          ],
          as: "company",
        },
      },
      {
        $lookup: {
          from: "users",
          localField: "phone",
          foreignField: "phone",
          as: "user",
        },
      },
      { $unwind: "$user" },
      { $unwind: "$company" },
      {
        $project: {
          name: "$user.name",
          phone: "$user.phone",
          companyName: "$company.companyName",
          companyCity: "$company.city",
          companyToken: "$company.companyToken",
        },
      },
    ]);

    return res.status(200).json(results);
  } catch (error) {
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.approveOrRejectSchoolAdmin = async (req, res) => {
  try {
    const { approve, schoolAdminPhone } = req.body;
    let schoolAdmin = await SchoolAdministrator.findOne({
      phone: schoolAdminPhone,
    });
    let user = await User.findOne({ phone: schoolAdminPhone });

    if (approve) {
      schoolAdmin.isApproved = true;
      await schoolAdmin.save();
      sendCustomMessage(
        schoolAdminPhone,
        "İdari okul yöneticisi hesabınız onaylanmıştır. Belirlediğiniz şifre ile sisteme giriş yapabilirsiniz."
      );
    } else {
      if (user.canHaveRoles.length > 1) {
        const index = user.canHaveRoles.indexOf("SCHOOL_ADMINISTRATOR");
        user.canHaveRoles.splice(index, 1); //2nd parameter means remove one item only
        if (user.role == "SCHOOL_ADMINISTRATOR") {
          user.role = user.canHaveRoles[0];
        }
        await user.save();
      } else {
        await user.remove();
      }
      await schoolAdmin.remove();

      sendCustomMessage(
        schoolAdminPhone,
        "İdari şoför hesabı oluşturma isteğiniz reddedilmiştir."
      );
    }

    return res.status(200).json({
      msg:
        "Approval operation is successfully completed for school admin with phone " +
        schoolAdminPhone,
    });
  } catch (error) {
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getUnapprovedSchoolAdmins = async (req, res) => {
  try {
    let schoolAdmins = await SchoolAdministrator.find({
      isApproved: false,
    }).populate("school");

    let result = await Promise.all(
      schoolAdmins.map(async (admin) => {
        let user = await User.findOne({ phone: admin.phone });
        return {
          phone: admin.phone,
          name: user.name,
          title: admin.title,
          schoolName: admin.school.name,
        };
      })
    );
    return res.status(200).json(result);
  } catch (error) {
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.approveOrRejectCompany = async (req, res) => {
  try {
    const { approve, companyID } = req.body;

    let company = await Company.findById(companyID);

    if (approve) {
      company.isApproved = true;
      await company.save();
      sendCustomMessage(
        company.whoAddedCompanyPhone,
        "Eklediğiniz şirket onaylanmıştır. Belirlediğiniz şifre ile sisteme giriş yapabilirsiniz."
      );
      let companyAdmin = await CompanyAdmin.findOne({
        phone: company.whoAddedCompanyPhone,
      });
      companyAdmin.isApproved = true;
      await companyAdmin.save();
    } else {
      let companyAdmin = await CompanyAdmin.findOne({
        phone: company.whoAddedCompanyPhone,
      });
      sendCustomMessage(
        company.whoAddedCompanyPhone,
        "Eklediğiniz şirket onaylanmamıştır. Bilgilerin doğruluğunu teyit edip tekrar deneyebilirsiniz. Şirket adı:." +
          company.companyName
      );
      let user = await User.findOne({ phone: company.whoAddedCompanyPhone });

      if (user.canHaveRoles.length > 1) {
        const index = user.canHaveRoles.indexOf("COMPANY_ADMIN");
        user.canHaveRoles.splice(index, 1); //2nd parameter means remove one item only
        if (user.role == "COMPANY_ADMIN") {
          user.role = user.canHaveRoles[0];
        }
        await user.save();
      } else {
        await user.remove();
      }
      await company.remove();
      await companyAdmin.remove();
    }

    return res.status(200).json({
      msg:
        "Approval operation is successfully completed for company with companyID " +
        companyID,
    });
  } catch (error) {
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getUnapprovedCompanies = async (req, res) => {
  try {
    let companies = await Company.find({ isApproved: false });
    return res.status(200).json(companies);
  } catch (error) {
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.addAdmin = async (req, res) => {
  try {
    const { username, password } = req.body;

    let exist = await Admin.findOne({ username: username });

    if (exist) {
      return res.status(400).json({ msg: "Admin exists with this username." });
    }

    const hashedPassword = await bcrypt.hash(password, 12);

    let admin = new Admin({
      username: username,
      password: hashedPassword,
    });

    await admin.save();
    return res.status(200).json({
      msg: "Admin is created.",
      admin: admin,
    });
  } catch (error) {
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.adminLogin = async (req, res) => {
  try {
    const { username, password } = req.body;

    let admin = await Admin.findOne({ username: username });

    if (!admin) {
      return res.status(400).json({ msg: "Invalid Credentials." });
    }

    const passwordMatches = await bcrypt.compare(password, admin.password);

    if (!passwordMatches) {
      return res.status(400).json({ msg: "Invalid Credentials." });
    }

    admin = {
      id: admin.id,
      username: admin.username,
    };

    const token = jwt.sign(admin, process.env.JWTSECRET);

    return res.status(200).json({ result: admin, token });
  } catch (error) {
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getAdminList = async (req, res) => {
  try {
    let admins = await Admin.find().select("-password");
    return res.status(200).json(admins);
  } catch (error) {
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};
