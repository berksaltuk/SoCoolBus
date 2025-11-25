import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/driver/components/student_list_item.dart';
import 'package:my_app/driver/components/student_raise_list_item.dart';
import 'package:my_app/models/school.dart';
import 'package:my_app/models/student.dart';

import '../../constants.dart';
import 'package:http/http.dart' as http;

class MakeRaiseScreen extends StatefulWidget {
  const MakeRaiseScreen({super.key});

  @override
  State<MakeRaiseScreen> createState() => _MakeRaiseScreenState();
}

class _MakeRaiseScreenState extends State<MakeRaiseScreen> {
  School? selectedSchool;
  bool homeToSchool = true;
  bool isMorningPerson = true;

  List<Student> _studentList = [];
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
            onWillPop: () async => true,
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
                onWillPop: () async => true,
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text(
                      'Öğrenci Bilgileri',
                    ),
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
                                      return ListView.builder(
                                        itemCount: snapshot.data!.length,
                                        itemBuilder: (context, index) {
                                          final student = snapshot.data![index];
                                          return StudentRaiseList(
                                            studentId: student.studentId,
                                            index: index,
                                            key: ValueKey(student),
                                            name: student.name,
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

  void _refreshPage() {
    setState(() {});
  }

  Future<List<Student>> getDriverSchoolStudentsBySchoolStartTime(
      School? school, bool h2s, bool isMorningPerson) async {
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
}
