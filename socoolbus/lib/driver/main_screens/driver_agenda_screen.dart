import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/components/select_child.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/driver/components/driver_agenda_note.dart';
import 'package:my_app/driver/components/select_school.dart';
import 'package:my_app/models/note.dart';
import 'package:my_app/models/school.dart';
import 'package:my_app/models/student.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class DriverAgendaScreen extends StatefulWidget {
  const DriverAgendaScreen({super.key});

  @override
  _AgendaState createState() => _AgendaState();
}

class _AgendaState extends State<DriverAgendaScreen> {
  CalendarFormat format = CalendarFormat.week;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  School? _selectedSchool;
  Student? _selectedStudent;
  TextEditingController noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Takvim',
              style: TextStyle(fontSize: 20),
            ),
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 30)),
                      focusedDay: selectedDay,
                      calendarFormat: format,
                      locale: "tr_TR",
                      onFormatChanged: (CalendarFormat _format) {
                        setState(() {
                          format = _format;
                        });
                      },
                      onDaySelected: (DateTime selectDay, DateTime focusDay) {
                        setState(() {
                          selectedDay = selectDay;
                          focusedDay = focusDay;
                        });
                        print(focusedDay);
                      },
                      selectedDayPredicate: (DateTime date) {
                        return isSameDay(selectedDay, date);
                      },
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      calendarStyle: CalendarStyle(
                        selectedDecoration: const BoxDecoration(
                          color: COLOR_DARK_GREY,
                          shape: BoxShape.circle,
                        ),
                        defaultTextStyle: TextStyle(fontSize: width * 0.07),
                        outsideTextStyle: TextStyle(fontSize: width * 0.07),
                        todayTextStyle: TextStyle(fontSize: width * 0.07),
                        holidayTextStyle: TextStyle(
                            fontSize: width * 0.07, color: COLOR_ORANGE),
                        weekendTextStyle: TextStyle(
                            fontSize: width * 0.07, color: COLOR_ORANGE),
                        disabledTextStyle: TextStyle(
                            color: COLOR_LIGHT_GREY, fontSize: width * 0.07),
                        weekNumberTextStyle: TextStyle(fontSize: width * 0.07),
                        selectedTextStyle: TextStyle(
                            color: COLOR_WHITE, fontSize: width * 0.07),
                        isTodayHighlighted: false,
                        weekendDecoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        titleTextStyle: const TextStyle(fontSize: 28),
                        formatButtonVisible: false,
                        titleCentered: true,
                        formatButtonShowsNext: false,
                        leftChevronIcon: const Icon(
                          size: 32,
                          Icons.chevron_left,
                          color: Colors.black,
                        ),
                        rightChevronIcon: const Icon(
                          size: 32,
                          Icons.chevron_right,
                          color: Colors.black,
                        ),
                        formatButtonDecoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Notlar",
                          style: Theme.of(context).textTheme.headline1,
                        ),

                        // add note button
                        ElevatedButton(
                            onPressed: () {
                              openDialog();
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        COLOR_ORANGE),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                  size: 20.0,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Not Ekle",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ))
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),

                    //height: 300,
                    height: MediaQuery.of(context).size.height * 0.48,

                    child: FutureBuilder<List<Note>>(
                      future: getDriverNote(selectedDay),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                                'Bir hata oluştu!\n${snapshot.error!.toString()}'),
                          );
                        } else if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text('Bugün için eklenen not yok.'),
                            );
                          }
                          return ListView(
                            children: [
                              for (var note in snapshot.data!)
                                DriverAgendaNote(
                                    person: note.student,
                                    school: note.school,
                                    issuedby: note.noteAdderType,
                                    note: note.description,
                                    date: DateTime.now().toUtc()),
                            ],
                          );
                        } else {
                          return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.black),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  openDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text("Not Ekle"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<List<School>>(
                    future: getDriverSchools(getUserPhone()),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Bir hata oluştu!'),
                        );
                      } else if (!snapshot.hasData) {
                        return const Center(
                          child: Text('Eklenen okulunuz yok!'),
                        );
                      } else if (snapshot.hasData) {
                        return DropdownButtonSchool(
                          list: snapshot.data!,
                          //width: MediaQuery.of(context).size.width * 0.70,
                          previewText: "Okul Seç",
                          searchText: "Okul Ara",
                          onChanged: (p0) {
                            setState(() {
                              _selectedSchool = p0;
                            });
                          },
                          selectedValue: _selectedSchool,
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                  _selectedSchool != null
                      ? FutureBuilder<List<Student>>(
                          future: getDriverSchoolStudents(_selectedSchool),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text(
                                  'An error has occurred!\n${snapshot.error}');
                            } else if (snapshot.hasData) {
                              return DropdownButtonChild(
                                list: snapshot.data!,
                                onChanged: (p0) {
                                  setState(() {
                                    _selectedStudent = p0;
                                  });
                                },
                                selectedValue: _selectedStudent,
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        )
                      : const SizedBox(),
                  TextField(
                    keyboardType: TextInputType.multiline,
                    controller: noteController,
                    autocorrect: false,
                    maxLines: 4,
                    maxLength: 140,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 2, color: COLOR_DARK_GREY),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 2, color: COLOR_LIGHT_GREY),
                      ),
                      hintText: 'Açıklama',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(COLOR_ORANGE)),
                  onPressed: () {
                    addNoteFromDriver(_selectedStudent!.studentId,
                        noteController.text, selectedDay);
                    Navigator.of(context).pop();
                    _selectedStudent = null;
                    noteController.text = "";
                  },
                  child: const Text("Ekle"),
                )
              ],
            );
          });
        });
  }

  void addNoteFromDriver(
      String studentId, String text, DateTime selectedDay) async {
    var url = Uri.http(deployURL, 'driver/addNote');

    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      "studentID": studentId,
      "description": text,
      "driverPhone": await getUserPhone(),
      "noteAdderType": "DRIVER",
      "date": DateUtils.dateOnly(selectedDay).toString(),
    });
    print(response.body);
    setState(() {});
  }

  Future<List<Note>> getDriverNote(DateTime selectedDay) async {
    var url = Uri.http(deployURL, 'driver/getNotes');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'driverPhone': await getUserPhone(),
      'date': DateUtils.dateOnly(selectedDay).toString(),
    });
    print(response.body);

    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<Note>((json) => Note.fromJson(json)).toList();
  }
}
