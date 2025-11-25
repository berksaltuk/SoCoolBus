import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/components/time_formatter.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/components/select_general.dart';
import 'package:my_app/driver/components/finance_button.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/driver/settings/driver_my_schools.dart';

import 'driver_add2_my_schools.dart';

class DriverDefineSchool extends StatefulWidget {
  const DriverDefineSchool({super.key});

  @override
  State<DriverDefineSchool> createState() => _DriverDefineSchoolState();
}

class _DriverDefineSchoolState extends State<DriverDefineSchool> {
  bool isTwoShift = false;
  String? selectedCity;
  bool isKindergarden = false;
  bool isPrimary = false;
  bool isSecondary = false;
  bool isHighSchool = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController firstDevreEnterenceController =
      TextEditingController();
  final TextEditingController firstDevreExitController =
      TextEditingController();
  final TextEditingController secondDevreEnteranceController =
      TextEditingController();
  final TextEditingController secondDevreExitController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          // ignore: prefer_const_constructors
          title: Text(
            'Okul Tanımla',
            style: const TextStyle(fontSize: 24),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //scrollable list
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            child: Text(
                              "Okul Bilgileri",
                              style: Theme.of(context).textTheme.headline2,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: size.width,
                        margin: const EdgeInsets.only(bottom: 10),
                        height: size.height * 0.3,
                        //padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            //border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            DropdownGeneral(
                              list: cityList,
                              searchable: true,
                              width: MediaQuery.of(context).size.width,
                              previewText: "Şehir Seç",
                              searchText: "Şehir Ara",
                              onChanged: (p0) {
                                setState(() {
                                  selectedCity = p0 as String;
                                });
                              },
                              selectedValue: selectedCity,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: TextField(
                                  controller: nameController,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 5.0, horizontal: 10),
                                    border: OutlineInputBorder(),
                                    hintText: 'Okul Adı Giriniz',
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(children: [
                                    Checkbox(
                                      checkColor: COLOR_BLACK,
                                      focusColor: COLOR_BLACK,
                                      activeColor: COLOR_GREY,
                                      value: isKindergarden,
                                      onChanged: (value) {
                                        setState(() {
                                          isKindergarden = value!;
                                        });
                                      },
                                    ),
                                    const Text("Anaokulu"),
                                  ]),
                                ),
                                Flexible(
                                  child: Row(children: [
                                    Checkbox(
                                      checkColor: Colors.orange,
                                      focusColor: Colors.black,
                                      activeColor: Colors.grey,
                                      value: isPrimary,
                                      onChanged: (value) {
                                        setState(() {
                                          isPrimary = value!;
                                        });
                                      },
                                    ),
                                    const Text("İlkokul"),
                                  ]),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(children: [
                                    Checkbox(
                                      checkColor: Colors.orange,
                                      focusColor: Colors.black,
                                      activeColor: Colors.grey,
                                      value: isSecondary,
                                      onChanged: (value) {
                                        setState(() {
                                          isSecondary = value!;
                                        });
                                      },
                                    ),
                                    const Text("Ortaokul"),
                                  ]),
                                ),
                                Flexible(
                                  child: Row(children: [
                                    Checkbox(
                                      checkColor: Colors.orange,
                                      focusColor: Colors.black,
                                      activeColor: Colors.grey,
                                      value: isHighSchool,
                                      onChanged: (value) {
                                        setState(() {
                                          isHighSchool = value!;
                                        });
                                      },
                                    ),
                                    const Text("Lise"),
                                  ]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  //operations
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child: Text(
                          "Okul Saatleri",
                          style: Theme.of(context).textTheme.headline2,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        width: size.width,
                        margin: const EdgeInsets.only(bottom: 10),
                        height: size.height * 0.24,
                        //padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            //border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: ListTile(
                                    title: Transform.translate(
                                      offset: Offset(-20, 0),
                                      child: Text(
                                        'Tek Devre',
                                        style: TextStyle(
                                          fontSize: 15.0,
                                        ),
                                      ),
                                    ),
                                    leading: Transform.translate(
                                      offset: Offset(-10, 0),
                                      child: Radio(
                                        value: false,
                                        groupValue: isTwoShift,
                                        onChanged: (value) {
                                          setState(() {
                                            isTwoShift = value!;
                                          });
                                        },
                                        activeColor: COLOR_BLACK,
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: ListTile(
                                    title: Transform.translate(
                                      offset: Offset(-20, 0),
                                      child: Text(
                                        'Çift Devre',
                                        style: TextStyle(
                                          fontSize: 15.0,
                                        ),
                                      ),
                                    ),
                                    leading: Transform.translate(
                                      offset: Offset(-10, 0),
                                      child: Radio(
                                        value: true,
                                        groupValue: isTwoShift,
                                        onChanged: (value) {
                                          setState(() {
                                            isTwoShift = value!;
                                          });
                                        },
                                        activeColor: COLOR_BLACK,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: SizedBox(
                                      height: size.height * 0.06,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        controller:
                                            firstDevreEnterenceController,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10),
                                          border: OutlineInputBorder(),
                                          hintText: 'Sabah Giriş Saati',
                                        ),
                                        inputFormatters: <TextInputFormatter>[
                                          TimeTextInputFormatter(
                                              hourMaxValue: 23,
                                              minuteMaxValue: 59)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: SizedBox(
                                      height: size.height * 0.06,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        controller: firstDevreExitController,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10),
                                          border: OutlineInputBorder(),
                                          hintText: 'Çıkış Saati',
                                        ),
                                        inputFormatters: <TextInputFormatter>[
                                          TimeTextInputFormatter(
                                              hourMaxValue: 23,
                                              minuteMaxValue: 59)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //Çift devreyse
                            isTwoShift
                                ? Row(
                                    children: [
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: SizedBox(
                                            height: size.height * 0.06,
                                            child: TextField(
                                              controller:
                                                  secondDevreEnteranceController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 5.0,
                                                        horizontal: 10),
                                                border: OutlineInputBorder(),
                                                hintText: 'Öğlen Giriş Saati',
                                              ),
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                TimeTextInputFormatter(
                                                    hourMaxValue: 23,
                                                    minuteMaxValue: 59)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Padding(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 5),
                                          child: SizedBox(
                                            height: size.height * 0.06,
                                            child: TextField(
                                              controller:
                                                  secondDevreExitController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 5.0,
                                                        horizontal: 10),
                                                border: OutlineInputBorder(),
                                                hintText: 'Çıkış Saati',
                                              ),
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                TimeTextInputFormatter(
                                                    hourMaxValue: 23,
                                                    minuteMaxValue: 59)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      FinanceButton(
                        //navigate to payment list page
                        onPressed: () {
                          addSchool(
                              nameController.text,
                              selectedCity!,
                              createSchoolTypeList(isKindergarden, isPrimary,
                                  isSecondary, isHighSchool),
                              isTwoShift,
                              firstDevreEnterenceController.text,
                              firstDevreExitController.text,
                              secondDevreEnteranceController.text,
                              secondDevreExitController.text);
                          setState(() {
                            final snackBar = SnackBar(
                              content:
                                  const Text('Okul ekleme isteği gönderildi.'),
                              action: SnackBarAction(
                                label: '',
                                onPressed: () {
                                  // Some code to undo the change.
                                },
                              ),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);

                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DriverAdd2MySchools(),
                              ),
                            );
                          });
                        },
                        child: Text(
                          'Gönder',
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ),
                      SizedBox(height: size.height * 0.001),
                      Text("Tanımlanan okulun onay için bekleyiniz."),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<String> createSchoolTypeList(
      bool kinder, bool prime, bool second, bool high) {
    List<String> list = [];
    if (kinder) {
      list.add("Anaokulu");
    }
    if (prime) {
      list.add("İlkokul");
    }
    if (second) {
      list.add("Ortaokul");
    }
    if (high) {
      list.add("Lise");
    }
    return list;
  }

  void addSchool(
      String name,
      String address,
      List<String> schoolType,
      bool isTwoShift,
      String firstDevreEnterence,
      String firstDevreExit,
      String secondDevreEnterance,
      String secondDevreExit) async {
    var url = Uri.http(deployURL, 'school/createSchool');
    int shiftCountNumber = isTwoShift ? 2 : 1;
    print(url);
    print(schoolType.toString());
    //TODO: need to check if address and school type null or not
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'name': name,
      'address': address,
      'schoolType': schoolType.toString(),
      'shiftCount': shiftCountNumber.toString(),
      'firstDevreEnterence': firstDevreEnterence,
      'firstDevreExit': firstDevreExit,
      'secondDevreEnterance': secondDevreEnterance,
      'secondDevreExit': secondDevreExit,
    });
    print(response.body);

    //const CircularProgressIndicator();
  }

  void addAccount(
      String name,
      String schoolId,
      String secondPhone,
      String address,
      String paymentPre,
      String whogondothepa,
      String addressDirections,
      String parentName,
      String parentPhone,
      bool isTwoWay,
      int schoolStartTime,
      bool homeToSchool,
      int duration,
      int totalFee) async {
    int directionPref = 0;
    int paymentPref = 0;
    int whogondothepay = 0;
    if (isTwoWay) {
      directionPref = 1;
    } else {
      if (homeToSchool) {
        directionPref = 2;
      } else {
        directionPref = 3;
      }
    }

    if (whogondothepa == 'Kurum') {
      whogondothepay = 1;
    } else if (whogondothepa == 'Okul') {
      whogondothepay = 2;
    }

    if (paymentPre == 'Yıllık') {
      paymentPref = 1;
    }
    var url = Uri.http(deployURL, 'student/createStudent');
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'name': name,
      'school': schoolId,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'secondPhone': secondPhone,
      'address': address,
      'directionPref': directionPref.toString(),
      'paymentPref': paymentPref.toString(),
      'whogondothepay': whogondothepay.toString(),
      'duration': duration.toString(),
      'totalFee': totalFee.toString(),
      'schoolStartTime': schoolStartTime.toString(),
      'driverPhone': await getUserPhone()
    });

    if (response.statusCode != 201) {
      throw Exception(response.body);
    } else if (response.statusCode == 201) {
      final snackBar = SnackBar(
        content: const Text('Öğrenci eklendi.'),
        action: SnackBarAction(
          label: '',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      Navigator.pop(context);
    }
  }
}
