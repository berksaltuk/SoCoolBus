import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_app/components/select_general.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/driver/components/due_date_school_list.dart';
import 'package:my_app/models/driver_due_date_config.dart';
import 'package:my_app/models/school.dart';

import 'package:http/http.dart' as http;
import '../../components/common_methods.dart';

class SelectDueDate extends StatefulWidget {
  const SelectDueDate({super.key});
  @override
  State<SelectDueDate> createState() => _SelectDueDateState();
}
class _SelectDueDateState extends State<SelectDueDate> {
  var days = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12",
    "13",
    "14",
    "15",
    "16",
    "17",
    "18",
    "19",
    "20",
    "21",
    "22",
    "23",
    "24",
    "25",
    "26",
    "27",
    "28",
    "29",
    "30",
    "31",
  ];

String? selectedDay;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tahsilat Tarihi Belirle"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50.0),
          child: FutureBuilder<List<School>>(
            future: getDriverSchools(getUserPhone()),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Bir hata oluştu!'),
                );
              } else if (snapshot.hasData) {
                return ListView(children: [
                  for (var school in snapshot.data!)
                    FutureBuilder<DriverDueDateConfig>(
                      future: getDriverDueDateConfig(
                          getUserPhone(), school.schoolId),
                      builder: (context, dueSnapshot) {
                        if (dueSnapshot.hasError) {
                          return Text("Bir hata oluştu!${dueSnapshot.error}");
                        } else if (dueSnapshot.hasData) {
                          return DueDateSchoolListItem(
                            dueId: dueSnapshot.data!.dueDateConfigId,
                            title: "Son ödeme tarihi:",
                            school: school.name,
                            paymentInfo: "Her ayın ${dueSnapshot.data!.date}. günü",
                            edit: SizedBox(
                              width: 30,
                              height: 20,
                              child: TextButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                ),
                                onPressed: () {
                                  openDialog(dueSnapshot.data!.date,
                                      dueSnapshot.data!.dueDateConfigId);
                                },
                                child: const Icon(Icons.edit),
                              ),
                            ),
                          );
                        } else {
                          return const CircularProgressIndicator(
                            color: COLOR_BLACK,
                          );
                        }
                      },
                    ),
                ]);
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    color: COLOR_BLACK,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future openDialog(String currentDay, String configId) => showDialog(
      context: context,
      builder: ((context) {
        
        return AlertDialog(
          title: const Text("Son Ödeme Tarihini Değiştir"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Şu anki son ödeme tarihi: $currentDay"),
              DropdownGeneral(
                searchable: false,
                list: days,
                onChanged: (value) {
                  setState(() {
                    selectedDay = value as String;
                  });
                },
                selectedValue: selectedDay,
              ),
            ],
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(COLOR_ORANGE)),
              onPressed: () {
                changeDueDate(configId, selectedDay!);
                Navigator.of(context).pop();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SelectDueDate()));
              },
              child: const Text("Değiştir"),
            )
          ],
        );
      }));

  Future<DriverDueDateConfig> getDriverDueDateConfig(
      Future<String> userPhone, String schoolId) async {
    var url = Uri.http(deployURL, 'driver/getDriverConfig');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'driverPhone': await userPhone,
      'schoolID': schoolId,
    });
    print(response.body);
    return DriverDueDateConfig.fromJson(jsonDecode(response.body)[0]);
  }
  
  void changeDueDate(String configId, String selectedDay) async {
    var url = Uri.http(deployURL, 'driver/updateDueDate');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'id': configId,
      'dueDate': selectedDay,
    });
    print(response.body);
  }
}
