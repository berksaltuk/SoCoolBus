const Account = require("../../models/account");

const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

module.exports.addAccount = async (req, res) => {
  try {
    let query = {
      ...req.body,
    };

    const account = new Account(query);
    await account.save();
    return res.status(200).send(account);
  } catch (error) {
    const { Logtail } = require("@logtail/node");
    const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.deleteIBAN = async (req, res) => {
  try {
    const account = await Account.findById(req.body.accountId);

    if (!account) {
      return res.status(404).send({ msg: "IBAN not found by given id." });
    }

    await account.remove();

    return res.status(200).send({ msg: "IBAN is deleted succesfully." });
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.updateAccount = async (req, res) => {
  try {
    const account = await Account.findById(req.body.id);

    if (req.body.iban) account.iban = req.body.iban;
    if (req.body.receiver) account.receiver = req.body.receiver;

    await account.save();
    logtail.info("Account updated with the ID: " + req.body.id);
    logtail.flush();
    return res.status(200).send(account);
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getAccountsByDriver = async (req, res) => {
  try {
    const accounts = await Account.find({ phone: req.body.phone });

    if (!accounts) {
      return res
        .status(404)
        .send({ success: false, errorMsg: "No accounts for driver." });
    }
    return res.status(200).send(accounts);
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};
