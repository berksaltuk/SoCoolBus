import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/components/custom_radio.dart';
import 'package:my_app/components/general_button.dart';
import 'package:my_app/models/student.dart';
import 'package:my_app/components/select_child.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class ParentPermissionScreen extends StatefulWidget {
  const ParentPermissionScreen({super.key});

  @override
  State<ParentPermissionScreen> createState() => _PermissionState();
}

class _PermissionState extends State<ParentPermissionScreen> {
  CalendarFormat format = CalendarFormat.week;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  Student? selectedStudent;
  int tempPermission = -1;
  TextEditingController noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon:
                Image.asset("assets/images/sy_logo.jpeg", fit: BoxFit.contain),
            onPressed: () => {},
          ),
          actions: const [],
          title: const Text("İzin İşlemleri"),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                FutureBuilder<List<Student>>(
                  future: getParentChildren(getUserPhone()),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Bir hata oluştu!'),
                      );
                    } else if (!snapshot.hasData) {
                      return const Center(
                          child: SizedBox(
                              height: 40,
                              child: LinearProgressIndicator(
                                color: COLOR_GREY,
                              )) //Text('Eklenen okulunuz yok!'),
                          );
                    } else if (snapshot.hasData) {
                      return Column(children: [
                        DropdownButtonChild(
                          list: snapshot.data!,
                          width: MediaQuery.of(context).size.width * 0.8,
                          onChanged: (p0) {
                            selectedStudent = p0;
                            getPermission(selectedStudent!, selectedDay)
                                .then((radioValue) {
                              tempPermission = radioValue;
                            });
                            setState(() {});
                          },
                          selectedValue: selectedStudent,
                        ),
                        TableCalendar(
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
                          onDaySelected:
                              (DateTime selectDay, DateTime focusDay) {
                            selectedDay = selectDay;
                            focusedDay = focusDay;
                            getPermission(selectedStudent!, selectedDay)
                                .then((radioValue) {
                              tempPermission = radioValue;
                            });
                            setState(() {});
                            print(focusedDay);
                          },
                          selectedDayPredicate: (DateTime date) {
                            return isSameDay(selectedDay, date);
                          },
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          calendarStyle: CalendarStyle(
                            selectedDecoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.rectangle,
                              //borderRadius: BorderRadius.all(Radius.circular(5)),
                            ),
                            defaultTextStyle: const TextStyle(fontSize: 32),
                            outsideTextStyle: const TextStyle(fontSize: 32),
                            todayTextStyle: const TextStyle(fontSize: 32),
                            holidayTextStyle: const TextStyle(fontSize: 32),
                            weekendTextStyle: const TextStyle(fontSize: 32),
                            disabledTextStyle: const TextStyle(
                                color: Color(0xFFBFBFBF), fontSize: 32),
                            weekNumberTextStyle: const TextStyle(fontSize: 32),
                            selectedTextStyle: const TextStyle(
                                color: Colors.white, fontSize: 32),
                            isTodayHighlighted: false,
                            weekendDecoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(5.0),
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
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "İzin Seçenekleri",
                              style: Theme.of(context).textTheme.headline1,
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.35),
                            GeneralButton(
                                onPressed: (() => {openDialog()}),
                                child: Row(
                                  children: const [
                                    Icon(Icons.note_alt, color: Colors.black),
                                    Text(
                                      "Not Ekle",
                                      style: TextStyle(color: Colors.black),
                                    )
                                  ],
                                ))
                          ],
                        ),
                        Container(
                            color: const Color.fromARGB(1, 240, 239, 244),
                            width: MediaQuery.of(context).size.width * 0.95,
                            height: MediaQuery.of(context).size.height * 0.30,
                            child: FutureBuilder<int>(
                              future:
                                  getPermission(selectedStudent, selectedDay),
                              builder: (context, radioSnapshot) {
                                if (radioSnapshot.hasError) {
                                  return Center(
                                    child: Text(radioSnapshot.error.toString()),
                                  );
                                } else if (radioSnapshot.hasData) {
                                  return Column(
                                    children: <Widget>[
                                      CustomRadioButton(
                                        text: "Servis Kullanacak",
                                        name: "Aziz Karaoğlu",
                                        index: 0,
                                        onPressed: () {
                                          tempPermission = 0;
                                          setState(() {});
                                          print(tempPermission);
                                        },
                                        selected: tempPermission,
                                      ),
                                      CustomRadioButton(
                                        text: "Sabah Servis Kullanmayacak",
                                        name: "Aziz Karaoğlu",
                                        index: 1,
                                        onPressed: () {
                                          tempPermission = 1;
                                          setState(() {});
                                          print(tempPermission);
                                        },
                                        selected: tempPermission,
                                      ),
                                      CustomRadioButton(
                                        text: "Akşam Servis Kullanmayacak",
                                        name: "Aziz Karaoğlu",
                                        index: 2,
                                        onPressed: () {
                                          tempPermission = 2;
                                          setState(() {});
                                          print(tempPermission);
                                        },
                                        selected: tempPermission,
                                      ),
                                      CustomRadioButton(
                                        text:
                                            "Sabah ve Akşam Servis Kullanmayacak",
                                        name: "Aziz Karaoğlu",
                                        index: 3,
                                        onPressed: () {
                                          tempPermission = 3;
                                          setState(() {});
                                        },
                                        selected: tempPermission,
                                      ),
                                    ],
                                  );
                                } else {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                            )),
                        GeneralButton(
                            onPressed: () {
                              changePermission(selectedStudent!, selectedDay,
                                  tempPermission);
                              final snackBar = SnackBar(
                                content:
                                    const Text('İzin tercihi değiştirildi.'),
                                action: SnackBarAction(
                                  label: '',
                                  onPressed: () {
                                    // Some code to undo the change.
                                  },
                                ),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            },
                            child: const Text(
                              "Kaydet",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ))
                      ]);
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ));
  }

  Future openDialog() => showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            title: const Text("Not Ekle"),
            content: TextField(
              keyboardType: TextInputType.multiline,
              autocorrect: false,
              maxLines: 4,
              maxLength: 140,
              controller: noteController,
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: COLOR_DARK_GREY),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: COLOR_LIGHT_GREY),
                ),
                hintText: 'Açıklama',
              ),
            ),
            actions: [
              TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(COLOR_ORANGE)),
                onPressed: () {
                  addNoteFromParent(
                      selectedStudent, noteController.text, selectedDay);
                    noteController.clear();
                  Navigator.of(context).pop();
                  final snackBar = SnackBar(
                    content: const Text('Not eklendi.'),
                    action: SnackBarAction(
                      label: '',
                      onPressed: () {
                        // Some code to undo the change.
                      },
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: const Text("Ekle"),
              )
            ],
          )));

  void changePermission(
      Student student, DateTime selectedDay, int permissionType) async {
    String permissionString = "";
    if (permissionType == 0) {
      permissionString = "none";
    } else if (permissionType == 1) {
      permissionString = "h2s";
    } else if (permissionType == 2) {
      permissionString = "s2h";
    } else if (permissionType == 3) {
      permissionString = "both";
    }
    updatePermission(student, selectedDay, permissionString);
  }

  void updatePermission(
      Student student, DateTime selectedDay, String permissionString) async {
    var url = Uri.http(deployURL, 'permission/updatePermission');
    print(url);
    print(student);
    print(permissionString);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'studentID': student.studentId,
      'date': DateUtils.dateOnly(selectedDay).toString(),
      'permissionType': permissionString,
      'phone': await getUserPhone(),
    });
    print(response.body);
  }

  Future<int> getPermission(Student? student, DateTime selectedDay) async {
    var url = Uri.http(deployURL, 'permission/getPermission');
    if (student == null) {
      return Future.error(
          "Öğrenciye tanımlı izni görmek için lütfen önce öğrenci seçimi yapın!");
    }
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'studentID': student.studentId,
      'date': DateUtils.dateOnly(selectedDay).toString(),
    });
    if (response.statusCode == 404) {
      return Future<int>.value(0);
    }
    print("${response.statusCode}This is response body: ${response.body}");
    var shifts = jsonDecode(response.body)["shiftName"];
    int tempVal = 0;
    if (shifts.contains("Sabah Giriş") || shifts.contains("Öğlen Giriş")) {
      tempVal++;
    }
    if (shifts.contains("Öğlen Çıkış") || shifts.contains("Akşam Çıkış")) {
      tempVal += 2;
    }

    return tempVal;
  }

  void addNoteFromParent(
      Student? selectedStudent, String text, DateTime selectedDay) async {
    var url = Uri.http(deployURL, 'driver/addNote');

    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      "studentID": selectedStudent!.studentId,
      "description": text,
      "noteAdderType": "PARENT",
      "date": DateUtils.dateOnly(selectedDay).toString(),
    });
    print(response.body);
  }
}
