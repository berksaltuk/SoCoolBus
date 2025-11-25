import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/driver/components/select_school.dart';
import 'package:my_app/driver/components/student_list_item.dart';
import 'package:my_app/driver/main_screens/driver_student_info_screen.dart';
import 'package:my_app/models/school.dart';
import 'package:my_app/models/student.dart';

import '../../constants.dart';
import 'package:http/http.dart' as http;

class EditOrder extends StatefulWidget {
  EditOrder(
      {super.key,
      required this.selectedSchool,
      required this.isMorningPerson,
      required this.onChangesMade});

  final School selectedSchool;
  final bool isMorningPerson;
  final Function onChangesMade;

  @override
  State<EditOrder> createState() => _EditOrder();
}

class _EditOrder extends State<EditOrder> {
  bool homeToSchool = true;
  List<Student> _studentList = [];
  bool isEditing = true;
  bool reordered = false;

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text(
              'Sıra Düzenleme',
            ),
            ElevatedButton(
              onPressed: !reordered
                  ? null
                  : () {
                      setState(() {
                        saveOrder(homeToSchool);
                        widget.onChangesMade();
                        Navigator.of(context).pop(reordered);
                      });
                    },
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ))),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: const Icon(
                          Icons.save,
                          color: COLOR_ORANGE,
                        )),
                  ],
                ),
              ]),
            )
          ]),
        ]),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.selectedSchool.toString() + " Öğrencileri",
                    style: TextStyle(fontSize: 14),
                  )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: ListTile(
                    title: const Text(
                      'Evden Okula',
                      style: TextStyle(fontSize: 14),
                    ),
                    leading: Radio(
                      value: true,
                      groupValue: homeToSchool,
                      onChanged: reordered
                          ? null
                          : (bool? value) {
                              setState(() {
                                homeToSchool = value!;
                              });
                            },
                      activeColor: COLOR_BLACK,
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text(
                      'Okuldan Eve',
                      style: TextStyle(fontSize: 14),
                    ),
                    leading: Radio(
                      value: false,
                      groupValue: homeToSchool,
                      onChanged: reordered
                          ? null
                          : (bool? value) {
                              setState(() {
                                homeToSchool = value!;
                              });
                            },
                      activeColor: COLOR_BLACK,
                      focusColor: COLOR_WHITE,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: size.width,
                height: size.height * 0.56,
                child: FutureBuilder<List<Student>>(
                  future: getDriverSchoolStudentsBySchoolStartTime(
                      widget.selectedSchool,
                      homeToSchool,
                      widget.isMorningPerson),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('An error has occurred!\n${snapshot.error}');
                    } else if (snapshot.hasData) {
                      return ReorderableListView(
                        buildDefaultDragHandles: true,
                        children: [
                          for (var index = 0;
                              index < snapshot.data!.length;
                              index++)
                            StudentList(
                              studentId: snapshot.data![index].studentId,
                              key: ValueKey(snapshot.data![index]),
                              name: snapshot.data![index].name,
                              phone: snapshot.data![index].secondPhone,
                              address: snapshot.data![index].addressLink,
                              editable: true,
                              index:
                                  index, // Pass the index as a parameter to the StudentList widget
                              updateParent: updateState,
                            ),
                        ],
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final item = snapshot.data!.removeAt(oldIndex);
                            snapshot.data!.insert(newIndex, item);
                            reordered = true;
                          });
                        },
                      );
                    } else if (snapshot.data != null &&
                        snapshot.data!.length < 1) {
                      return Text('Öğrenci ekli değil');
                    } else {
                      return const Center(
                          child: CircularProgressIndicator(
                        color: COLOR_BLACK,
                      ));
                    }
                  },
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: const Center(
                child: Text(
                  "Öğrencilerin yerlerini değiştirmek için basılı tutunuz.",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateState() {
    setState(() {});
  }

  Future<List<Student>> getDriverSchoolStudentsBySchoolStartTime(
      School? school, bool h2s, bool isMorningPerson) async {
    var url = Uri.http(deployURL, 'school/getSchoolStudentsByDriver');
    if (reordered) {
      return _studentList;
    }
    if (school == null) {
      return [];
    }
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'schoolID': school.schoolId,
      'driverPhone': await getUserPhone(),
      'direction': h2s ? "0" : "1",
      'schoolStartTime': isMorningPerson ? "0" : "1",
    });

    final parsed = jsonDecode(response.body).cast<Map<dynamic, dynamic>>();
    List<Student> studentListBack =
        parsed.map<Student>((json) => Student.fromJson(json)).toList();
    _studentList = studentListBack;
    return studentListBack;
  }

  void saveOrder(bool h2s) async {
    var url = Uri.http(deployURL, 'school/updateOrderByDriver');

    List<String> stuList = [];
    for (var i = 0; i < _studentList.length; i++) {
      stuList.add(_studentList[i].studentId);
    }

    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'direction': h2s ? "0" : "1",
      'studentIDs': stuList.toString(),
    });

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }
}
