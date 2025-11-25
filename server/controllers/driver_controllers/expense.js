const Expense = require("../../models/expense");
const AgendaEntry = require("../../models/agendaEntry");

const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

module.exports.addExpense = async (req, res) => {
  try {
    let query = {
      ...req.body,
    };

    /*const log = new Log({
      driver: req.body.phone,
      expenseType: req.body.expenseType,
      logType: "EXPENSE",
    });
    log.save();*/

    const expense = new Expense(query);
    await expense.save();

    const agendaEntry = new AgendaEntry({
      driver: req.body.phone,
      expense: expense._id,
      agendaEntryType: "EXPENSE",
      mainHeader: "Masraf",
      summary: req.body.amount + "₺ Gider",
      detailedDescription: "Gider: " + req.body.expenseType,
    });
    await agendaEntry.save();
    return res.status(200).send(expense);
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.viewTodaysExpense = async (req, res) => {
  try {
    var now = new Date();
    var startOfToday = new Date(
      now.getFullYear(),
      now.getMonth(),
      now.getDate()
    );
    let driverPhone = req.body.phone;

    const expenses = await Expense.find({
      date: { $gte: startOfToday },
      phone: driverPhone,
    });

    return res.status(200).send(expenses);
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getDriverExpense = async (req, res) => {
  try {
    let driverPhone = req.body.phone;

    const expenses = await Expense.find({
      phone: driverPhone,
    });

    return res.status(200).send(expenses);
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};
