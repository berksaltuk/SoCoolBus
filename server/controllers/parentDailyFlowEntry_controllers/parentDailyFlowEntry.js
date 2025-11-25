const ParentDailyFlowEntry = require("../../models/parentDailyFlowEntry");
const Student = require("../../models/student");
const { Parent } = require("../../models/user");

const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

module.exports.getTopParentDailyFlowEntries = async (req, res) => {
  // Only returns top 4 daily entries
  try {
    let parent = await Parent.findOne({ phone: req.body.parentPhone });
    const parentDailyFlowEntries = await ParentDailyFlowEntry.find({
      parent: parent,
    })
      .populate("student")
      .limit(4);

    return res.status(200).send(
      parentDailyFlowEntries.map((entry) => {
        return {
          mainHeader: entry.mainHeader,
          summary: entry.summary,
          studentName: entry.student.name,
          detailedDescription: entry.detailedDescription,
          time: entry.date.toLocaleTimeString([], {
            hour: "2-digit",
            minute: "2-digit",
          }),
          type: entry.entryType,
          amount: entry.amount,
        };
      })
    );
  } catch (error) {
    logtail.error(error.message);
    logtail.flush();
    console.error(error.message);
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getParentFlowEntriesByStudent = async (req, res) => {
  // Only returns top 4 daily entries
  try {
    let student = await Student.findById(req.body.studentID);
    let compare_begin = new Date(req.body.fromDate).setUTCHours(0, 0, 0, 0);
    let compare_end = new Date(req.body.toDate).setUTCHours(23, 59, 59, 999);
    const parentDailyFlowEntries = await ParentDailyFlowEntry.find({
      student: student,
      date: { $gte: compare_begin, $lte: compare_end },
    })
      .populate("student")
      .limit(4);

    return res.status(200).send(
      parentDailyFlowEntries.map((entry) => {
        return {
          mainHeader: entry.mainHeader,
          summary: entry.summary,
          studentName: student.name,
          detailedDescription: entry.detailedDescription,
          time: entry.date.toLocaleTimeString([], {
            hour: "2-digit",
            minute: "2-digit",
          }),
          type: entry.entryType,
          amount: entry.amount,
        };
      })
    );
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};
