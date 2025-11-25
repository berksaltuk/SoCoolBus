import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/models/parent_dailyflow.dart';
import 'package:my_app/models/student.dart';
import 'package:my_app/components/select_child.dart';
import '../constants.dart';
import 'components/parent_report_item.dart';
import 'package:http/http.dart' as http;

class ParentReportsScreen extends StatefulWidget {
  const ParentReportsScreen({super.key});

  @override
  _ParentReportState createState() => _ParentReportState();
}

class _ParentReportState extends State<ParentReportsScreen> {
  TextEditingController fromDateInput = TextEditingController();
  TextEditingController toDateInput = TextEditingController();
  Student? selectedStudent;
  late Future<List<Student>> stuList;

  @override
  void initState() {
    fromDateInput.text = ""; //set the initial value of text field
    toDateInput.text = ""; //set the initial value of text field
    stuList = getParentChildren(getUserPhone());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Image.asset("assets/images/sy_logo.jpeg", fit: BoxFit.contain),
          onPressed: () => {},
        ),
        title: const Text("Raporlar"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<List<Student>>(
              future: stuList,
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
                  return DropdownButtonChild(
                    list: snapshot.data!,
                    width: MediaQuery.of(context).size.width * 0.8,
                    onChanged: (p0) {
                      setState(() {
                        selectedStudent = p0;
                      });
                    },
                    selectedValue: selectedStudent,
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.80,
                ),
                IconButton(
                    onPressed: (() => {openDialog(context)}),
                    icon: const Icon(Icons.filter_alt_outlined))
              ],
            ),
            SingleChildScrollView(
              child: Container(
                width: size.width,
                margin: const EdgeInsets.only(bottom: 10),
                height: size.height * 0.56,
                child: FutureBuilder<List<ParentDailyFlow>>(
                  future: getParentDailyFlowEntriesByStudent(
                      selectedStudent, fromDateInput.text, toDateInput.text),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error!.toString()),
                      );
                    } else if (snapshot.hasData) {
                      if (snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('Gösterilecek gündem yok!'),
                        );
                      }
                      return ListView(
                        children: [
                          for (var dailyFlow in snapshot.data!)
                            ParentReportItem(
                                mainHeader: dailyFlow.mainHeader,
                                studentName: dailyFlow.studentName,
                                summary: dailyFlow.summary,
                                detailedDescription:
                                    dailyFlow.detailedDescription,
                                dateof: dailyFlow.time),
                        ],
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future openDialog(BuildContext context) => showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            title: const Text("Filtreler"),
            actions: [
              TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(COLOR_ORANGE)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Filtrele"),
              )
            ],
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  height: MediaQuery.of(context).size.width / 5,
                  child: Center(
                      child: TextField(
                    controller: fromDateInput,
                    //editing controller of this TextField
                    decoration: const InputDecoration(
                        iconColor: Colors.black,
                        icon: Icon(Icons.calendar_today), //icon of text field
                        labelText:
                            "Başlangıç Tarihi Girin" //label text of field
                        ),
                    readOnly: false,
                    //set it true, so that user will not able to edit text
                    onTap: () async {
                      //DateTime? pickedDate;
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        confirmText: "Seç",
                        cancelText: "İptal",
                        initialDate: DateTime.now(),
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 30)),
                        //DateTime.now() - not to allow to choose before today.
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Colors.orangeAccent, // <-- SEE HERE
                                onPrimary: Colors.black, // <-- SEE HERE
                                onSurface: Colors.black, // <-- SEE HERE
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  primary: Colors.orange, // button text color
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                        //currentDate: pickedDate
                      );

                      if (pickedDate != null) {
                        print(
                            pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                        print(
                            formattedDate); //formatted date output using intl package =>  2021-03-16
                        setState(() {
                          fromDateInput.text =
                              formattedDate; //set output date to TextField value.
                        });
                      } else {
                        print("some error meh");
                        fromDateInput.text = "tarih seçilemedi...";
                      }
                    },
                  )),
                ),
                Container(
                  padding: const EdgeInsets.all(15),
                  height: MediaQuery.of(context).size.width / 5,
                  child: Center(
                      child: TextField(
                    controller: toDateInput,
                    //editing controller of this TextField
                    decoration: const InputDecoration(
                        iconColor: Colors.black,
                        icon: Icon(Icons.calendar_today), //icon of text field
                        labelText: "Bitiş Tarihi Girin" //label text of field
                        ),
                    readOnly: false,
                    //set it true, so that user will not able to edit text
                    onTap: () async {
                      //DateTime? pickedDate;
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        confirmText: "Seç",
                        cancelText: "İptal",
                        initialDate: DateTime.now(),
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 30)),
                        //DateTime.now() - not to allow to choose before today.
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Colors.orangeAccent, // <-- SEE HERE
                                onPrimary: Colors.black, // <-- SEE HERE
                                onSurface: Colors.black, // <-- SEE HERE
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  primary: Colors.orange, // button text color
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                        //currentDate: pickedDate
                      );

                      if (pickedDate != null) {
                        print(
                            pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                        print(
                            formattedDate); //formatted date output using intl package =>  2021-03-16
                        setState(() {
                          toDateInput.text =
                              formattedDate; //set output date to TextField value.
                        });
                      } else {
                        print("some error meh");
                        fromDateInput.text = "tarih seçilemedi...";
                      }
                    },
                  )),
                ),
              ],
            ),
          )));
}

Future<List<ParentDailyFlow>> getParentDailyFlowEntriesByStudent(
    Student? selectedStudent, String fromDate, String toDate) async {
  var url = Uri.http(deployURL, 'parent/getParentFlowEntriesByStudent');

  if (selectedStudent == null) {
    return Future.error("Lütfen öğrenci seçiniz");
  }
  if (fromDate == "" || toDate == "") {
    return Future.error("Lütfen tarih seçiniz");
  }
  print(url);
  print(toDate);
  final response = await http.post(url, headers: {
    HttpHeaders.authorizationHeader: await getUserToken(),
    "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
  }, body: {
    'studentID': selectedStudent.studentId,
    'fromDate': fromDate,
    'toDate': toDate,
  });
  print(response.body);

  final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
  return parsed
      .map<ParentDailyFlow>((json) => ParentDailyFlow.fromJson(json))
      .toList();
}
