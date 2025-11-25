const Note = require("../../models/note");
const SchoolBus = require("../../models/schoolBus.js");
const { Driver } = require("../../models/user.js");

const { Logtail } = require("@logtail/node");
const logtail = new Logtail("jwdwNd3p8Ng8u8MCVs8LVADf");

module.exports.addNote = async (req, res) => {
  try {
    let { studentID, description, noteAdderType, date } = req.body;
    if (noteAdderType != "PARENT" && noteAdderType != "DRIVER") {
      return res.status(400).send({ msg: "Invalid note adder type!" });
    }

    let schoolBus = await SchoolBus.findOne({ students: studentID });
    let driver = await Driver.findOne({ bus: schoolBus._id });

    const note = new Note({
      student: studentID,
      description: description,
      noteAdderType: noteAdderType,
      driverPhone: driver.phone,
      date: date,
    });

    await note.save();
    return res.status(200).send(note);
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.updateNoteDescription = async (req, res) => {
  try {
    let { id, description } = req.body;

    const note = await Note.findById(id);
    note.description = description;

    await note.save();
    return res.status(200).send(note);
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};

module.exports.getNotes = async (req, res) => {
  try {
    let { driverPhone } = req.body;

    let query = {
      driverPhone: driverPhone,
    };
    let date = new Date(req.body.date);

    let compare_begin = date.setUTCHours(0, 0, 0, 0);
    let compare_end = date.setUTCHours(23, 59, 59, 999);

    query.date = {
      $gte: compare_begin,
      $lte: compare_end,
    };

    const notes = await Note.find(query).populate({
      path: "student",
      populate: {
        path: "school",
      },
    });

    return res.status(200).send(
      notes.map((note) => {
        return {
          _id: note._id,
          student: note.student?.name,
          school: note.student?.school?.name,
          noteAdderType: note.noteAdderType,
          description: note.description,
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

module.exports.deleteNote = async (req, res) => {
  try {
    const note = await Note.findById(req.body.id);

    if (!note) {
      return res.status(404).send({ msg: "Note not found by given id." });
    }

    await note.remove();

    return res.status(200).send({ msg: "Note is deleted succesfully." });
  } catch (error) {
    console.error(error.message);
    logtail.error(error.message);
    logtail.flush();
    return res.status(500).send({ msg: "Server Error: " + error.message });
  }
};
