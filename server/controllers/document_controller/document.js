const Document = require("../../models/document");
const { User } = require("../../models/user");
require("dotenv").config();
const PDFDocument = require("pdfkit");
const crypto = require("crypto");
const axios = require("axios");
const fs = require("fs");
const path = require("path");
const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

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

const randomFileName = (bytes = 32) =>
  crypto.randomBytes(bytes).toString("hex");

const multer = require("multer");
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

module.exports.setMulter = upload.single("file");

module.exports.uploadFile = async (req, res) => {
  try {
    const fileName = randomFileName();
    const params = {
      Bucket: bucketName,
      Key: fileName,
      Body: req.file.buffer,
      ContentType: req.file.mimetype,
    };

    const command = new PutObjectCommand(params);

    await s3.send(command);

    const driverUser = await User.findOne({ phone: req.body.driverPhone });

    const docName =
      req.body.documentType == "LICENSE"
        ? "Ehliyet"
        : req.body.documentType == "REGISTRATION"
        ? "Ruhsat"
        : req.body.documentType == "PSYCHOTECHNIC"
        ? "Psikoteknik"
        : req.body.documentType == "IDENTIFICATION"
        ? "Kimlik"
        : req.body.documentType == "SRC"
        ? "Src"
        : req.body.documentType == "INSURANCE"
        ? "Z. Sigorta Poliçesi"
        : "Tuvtürk Muayene";

    const documentQuery = {
      documentType: req.body.documentType,
      driverPhone: req.body.driverPhone,
      fileName: fileName,
      documentName: driverUser.name + " - " + docName,
      documentNote: req.body.documentNote,
      documentDate: req.body.documentDate,
    };

    const document = new Document(documentQuery);

    document.save();

    return res.status(200).send(document);
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.retrieveFile = async (req, res) => {
  try {
    let doc = await Document.findById(req.body.id);

    const getObjectParams = {
      Bucket: bucketName,
      Key: doc.fileName,
    };
    const command = new GetObjectCommand(getObjectParams);

    const url = await getSignedUrl(s3, command, { expiresIn: 3600 });
    axios({
      method: "get",
      url: url,
      responseType: "stream",
    }).then(function (response) {
      const contentType = response.headers["content-type"];

      if (contentType.startsWith("image/")) {
        const imagePath = path.join(__dirname, "temp", "image.jpg");
        const imageDir = path.dirname(imagePath);

        if (!fs.existsSync(imageDir)) {
          fs.mkdirSync(imageDir, { recursive: true });
        }

        const outputStream = fs.createWriteStream(imagePath);

        response.data.pipe(outputStream);

        outputStream.on("finish", function () {
          let doc = new PDFDocument({ margin: 50 });
          doc.image(imagePath, {
            fit: [500, 400],
            align: "center",
            valign: "center",
          });
          doc.end();

          doc.pipe(res); // Move this line here
        });
      } else {
        return response.data.pipe(res);
      }
    });
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getFiles = async (req, res) => {
  // Only for listing purposes, to retrieve file use retrieveFile
  try {
    const docs = await Document.find({ driverPhone: req.body.driverPhone });

    return res.status(200).send(docs);
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.deleteFile = async (req, res) => {
  try {
    const doc = await Document.findById(req.body.id);
    if (!doc) {
      return res.status(404).send("File does not exist.");
    }

    const params = {
      Bucket: bucketName,
      Key: doc.fileName,
    };

    const command = new DeleteObjectCommand(params);
    await s3.send(command);
    await doc.remove();

    return res.status(200).send({ msg: "Delete operation is successful." });
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};
