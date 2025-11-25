import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/driver/components/select_school.dart';
import 'package:my_app/driver/components/student_list_item.dart';
import 'package:my_app/models/school.dart';
import 'package:my_app/models/student.dart';

import '../../constants.dart';
import 'package:http/http.dart' as http;

import '../sub_students/edit_order.dart';

class DriverStudentInfoScreen extends StatefulWidget {
  const DriverStudentInfoScreen({super.key});

  @override
  State<DriverStudentInfoScreen> createState() =>
      _DriverStudentInfoScreenState();
}

class _DriverStudentInfoScreenState extends State<DriverStudentInfoScreen> {
  School? selectedSchool;
  bool homeToSchool = true;
  bool isMorningPerson = true;
  bool isReorderable = false;

  List<Student> _studentList = [];
  bool _isEditing = false;
  bool _isLoaded = false;
  bool _noSchoolChosen = false;

  @override
  initState() {
    super.initState();
    getSelectedSchool().then((value1) {
      findSchoolById(value1!).then(
        (value2) {
          setState(() {
            selectedSchool = value2;
            _isLoaded = true;
          });
        },
      ).onError(((error, stackTrace) {
        print("Hata");
        setState(() {
          _noSchoolChosen = true;
          _isLoaded = true;
        });
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return _noSchoolChosen
        ? WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
                appBar: AppBar(
                  title: Column(children: const [
                    Text(
                      'Öğrenci Bilgileri',
                    )
                  ]),
                  automaticallyImplyLeading: false,
                ),
                body: const Center(
                    child: Text(
                        "Okul seçilmedi lütfen ana sayfadan okul seçimi yapıp devam ediniz!"))))
        : _isLoaded
            ? WillPopScope(
                onWillPop: () async => false,
                child: Scaffold(
                  appBar: AppBar(
                    title: Column(children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                            ),
                            const Text(
                              'Öğrenci Bilgileri',
                            ),
                            ElevatedButton(
                              onPressed: selectedSchool == null
                                  ? null
                                  : () {
                                      _navigateAndDisplaySelection(
                                        context,
                                        selectedSchool!,
                                        isMorningPerson,
                                      );
                                      /* setState(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditOrder(
                                selectedSchool: selectedSchool!,
                                isMorningPerson: isMorningPerson,
                              ),
                            ),
                          );
                          
                        }); */
                                    },
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ))),
                              child: Column(children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.05,
                                      child: const SizedBox(
                                          child: Icon(
                                        Icons.format_line_spacing_rounded,
                                        color: COLOR_ORANGE,
                                      )),
                                    ),
                                  ],
                                ),
                              ]),
                            )
                          ]),
                    ]),
                    automaticallyImplyLeading: false,
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (selectedSchool?.shiftCount == 2)
                            Container(
                              height: MediaQuery.of(context).size.height * 0.05,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: ListTile(
                                      title: const Text(
                                        'Sabahçı',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      leading: Radio(
                                        value: true,
                                        groupValue: isMorningPerson,
                                        onChanged: (value) {
                                          setState(() {
                                            isMorningPerson = value!;
                                          });
                                        },
                                        activeColor: Colors.black,
                                        //focusColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      title: const Text(
                                        'Öğlenci',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      leading: Radio(
                                        value: false,
                                        groupValue: isMorningPerson,
                                        onChanged: (value) {
                                          setState(() {
                                            isMorningPerson = value!;
                                          });
                                        },
                                        activeColor: Colors.black,
                                        focusColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  //sort button
                                ],
                              ),
                            ),
                          if (selectedSchool != null && _isEditing)
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
                                      onChanged: (value) {
                                        setState(() {
                                          homeToSchool = value!;
                                        });
                                      },
                                      activeColor: Colors.black,

                                      //focusColor: Colors.white,
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
                                      onChanged: (value) {
                                        setState(() {
                                          homeToSchool = value!;
                                        });
                                      },
                                      activeColor: Colors.black,
                                      focusColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: size.width,
                            height: size.height * 0.56,
                            child: FutureBuilder<List<Student>>(
                              future: getDriverSchoolStudentsBySchoolStartTime(
                                  selectedSchool,
                                  homeToSchool,
                                  isMorningPerson),
                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return snapshot.hasData
                                        ? const Center(
                                            child: CircularProgressIndicator(
                                              color: COLOR_BLACK,
                                            ),
                                          )
                                        : const Text("Bekleniyor...");
                                  case ConnectionState.done:
                                  default:
                                    if (snapshot.hasError) {
                                      return Text(
                                          'An error has occurred!\n${snapshot.error}');
                                    } else if (snapshot.hasData) {
                                      return isReorderable
                                          ? ReorderableListView(
                                              buildDefaultDragHandles: true,
                                              children: [
                                                for (var index = 0;
                                                    index <
                                                        snapshot.data!.length;
                                                    index++)
                                                  StudentList(
                                                    studentId: snapshot
                                                        .data![index].studentId,
                                                    key: ValueKey(
                                                        snapshot.data![index]),
                                                    name: snapshot
                                                        .data![index].name,
                                                    phone: snapshot.data![index]
                                                        .secondPhone,
                                                    address: snapshot
                                                        .data![index]
                                                        .addressLink,
                                                    editable: true,
                                                    index: index,
                                                    updateParent: _refreshPage,
                                                  ),
                                              ],
                                              onReorder: (oldIndex, newIndex) {
                                                setState(() {
                                                  if (oldIndex < newIndex) {
                                                    newIndex -= 1;
                                                  }
                                                  final item = snapshot.data!
                                                      .removeAt(oldIndex);
                                                  snapshot.data!
                                                      .insert(newIndex, item);
                                                });
                                              },
                                            )
                                          : ListView.builder(
                                              itemCount: snapshot.data!.length,
                                              itemBuilder: (context, index) {
                                                final student =
                                                    snapshot.data![index];
                                                return StudentList(
                                                  studentId: student.studentId,
                                                  index: index,
                                                  key: ValueKey(student),
                                                  name: student.name,
                                                  phone: student
                                                      .secondPhone, //Should changed to preferred phone
                                                  address: student.addressLink,
                                                  editable: false,
                                                  updateParent: _refreshPage,
                                                );
                                              },
                                            );
                                    } else {
                                      return const Text('Öğrenci Bulunamadı');
                                    }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.black));
  }

  Future<void> _navigateAndDisplaySelection(
      BuildContext context, School school, bool isMorning) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditOrder(
                selectedSchool: school,
                isMorningPerson: isMorning,
                onChangesMade: _refreshPage,
              )),
    );

    // When a BuildContext is used from a StatefulWidget, the mounted property
    // must be checked after an asynchronous gap.
    if (!mounted) return;

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    String out;
    if (result) {
      out = "Değişiklikler kaydedildi.";
    } else {
      out = "Değişiklik yapılmadı.";
    }
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$out')));
  }

  void _refreshPage() {
    setState(() {});
  }

  Future<List<Student>> getDriverSchoolStudentsBySchoolStartTime(
      School? school, bool h2s, bool isMorningPerson) async {
    if (_isEditing) {
      return _studentList;
    }
    var url = Uri.http(deployURL, 'school/getSchoolStudentsByDriver');
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
    print(response.body);

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
