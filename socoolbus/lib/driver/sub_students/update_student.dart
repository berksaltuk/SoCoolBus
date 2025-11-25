import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_app/components/common_methods.dart';
import 'dart:convert';
import 'package:my_app/components/select_general.dart';
import 'package:my_app/driver/components/finance_button.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/driver/components/select_school.dart';
import 'package:my_app/models/school.dart';
import 'package:my_app/models/parent.dart';
import 'package:my_app/my_enum.dart';
import '../../components/phone_field.dart';
import '../../constants.dart';

//returns false if it is a valid phone number keep that in mind
/*
bool isvalidPhoneNumber(String input) {
  for (int i = 0; i < input.length; i++) {
    int charCode = input.codeUnitAt(i);
    //checks also the + and the whitespace characters other than numeric values
    if (charCode == 32 || charCode == 43 || (charCode > 48 && charCode < 57)) {
      return false;
    }
  }
  return true;
}*/

String capitalizeFirstLetter(String text) {
  if (text == null || text.isEmpty) {
    return '';
  }
  return text
      .split(' ')
      .map((word) => word.length > 1
          ? word[0].toUpperCase() + word.substring(1).toLowerCase()
          : word.toUpperCase())
      .join(' ');
}

bool schoolContains(School s, String type) {
  return s.schoolType
      .toString()
      .substring(1, s.schoolType.toString().length - 1)
      .toString()
      .contains(type);
}

bool isvalidPhoneNumber(String phoneNumber) {
  final RegExp phoneRegex = RegExp(
    r'^(\+?90)?( )?\d{3}( )?\d{3}( )?\d{2}( )?\d{2}$',
    caseSensitive: false,
    multiLine: false,
  );
  return !phoneRegex.hasMatch(phoneNumber);
}

String makePhoneValidAgain(String inputString) {
  if (inputString.length < 3) {
    return inputString;
  }

  if (inputString.substring(0, 3) == "+90") {
    // check if first three characters match "+90"
    inputString = inputString.substring(3);
  }

  inputString = inputString.replaceAll(' ', '');

  return inputString;
}

bool oneIsBeforeOther(String x, String y) {
  int xx = int.parse(x);
  int yy = int.parse(y);
  if (xx < yy) {
    return true;
  } else {
    return false;
  }
}

class DriverUpdateStudent extends StatefulWidget {
  final String studentId;
  const DriverUpdateStudent({required this.studentId, super.key});

  @override
  State<DriverUpdateStudent> createState() => _DriverUpdateStudentState();
}

class _DriverUpdateStudentState extends State<DriverUpdateStudent> {
  bool isTwoWay = true;
  int schoolStartTime = 2;
  bool homeToSchool = true;
  PaymentPreference paymentPreference = PaymentPreference.montly;
  PaymentWho paymentwho = PaymentWho.parent;
  String? duration;
  int totalFee = 0;
  School? selectedSchool;
  String? selectedClass;
  String? errorText;
  String? errorText2;
  String? errorText3;
  String? errorText4;

  double extra = 0;

  List classList = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController parPhoneController = TextEditingController();
  final TextEditingController parNameController = TextEditingController();
  final TextEditingController secPhoneController = TextEditingController();
  final TextEditingController addrController = TextEditingController();
  final TextEditingController monthlyFeeController =
      TextEditingController(text: "0");

  bool _isLoaded = false;

  @override
  initState() {
    getStudentInfo(widget.studentId).then((json) {
      nameController.text = json["name"];
      parPhoneController.text = json["parentPhone"];
      //parNameController.text = json["parentName"];
      secPhoneController.text = json["secondPhone"];
      addrController.text = json["adress"]["address"];
      monthlyFeeController.text = json["amount"].toString();

      paymentPreference = paymentPreference.fromInt(json["paymentPreference"]);
      paymentwho = paymentwho.fromInt(json["whogondothePayment"]);

      isTwoWay = json["directionPreference"] == 1;
      selectedClass = json["class"].toString();
      schoolStartTime = json["schoolStartTime"];

      findSchoolById(json["schoolID"]).then((value) {
        selectedSchool = value;
        if (schoolContains(selectedSchool!, "Anaokulu")) {
          classList.add(["Anaokulu"]);
        }
        if (schoolContains(selectedSchool!, "İlkokul")) {
          classList.addAll(["1", "2", "3", "4"]);
        }
        if (schoolContains(selectedSchool!, "Ortaokul")) {
          classList.addAll(["5", "6", "7", "8"]);
        }
        if (schoolContains(selectedSchool!, "Lise")) {
          classList.addAll(["9", "10", "11", "12"]);
        }
        setState(() {
          _isLoaded = true;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return _isLoaded
        ? WillPopScope(
            onWillPop: () async => true,
            child: Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Öğrenci Güncelle',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              body: ListView(children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  child: Text(
                                    "Öğrenci Bilgileri",
                                    style:
                                        Theme.of(context).textTheme.headline2,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: size.width,
                              margin: const EdgeInsets.only(bottom: 10),
                              //height: size.height * 0.50,
                              height: (size.height * 0.4) + extra,
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10)),
                              child: ListView(
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.70,
                                          previewText: "Okul Seç",
                                          searchText: "Okul Ara",
                                          onChanged: (p0) {
                                            setState(() {
                                              classList = [];
                                              selectedSchool = p0;
                                              print(selectedSchool);
                                              if (schoolContains(
                                                  selectedSchool!,
                                                  "Anaokulu")) {
                                                classList.add(["Anaokulu"]);
                                              }
                                              if (schoolContains(
                                                  selectedSchool!, "İlkokul")) {
                                                classList.addAll(
                                                    ["1", "2", "3", "4"]);
                                              }
                                              if (schoolContains(
                                                  selectedSchool!,
                                                  "Ortaokul")) {
                                                classList.addAll(
                                                    ["5", "6", "7", "8"]);
                                              }
                                              if (schoolContains(
                                                  selectedSchool!, "Lise")) {
                                                classList.addAll(
                                                    ["9", "10", "11", "12"]);
                                              }
                                            });
                                          },
                                          selectedValue: selectedSchool,
                                        );
                                      } else {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                    },
                                  ),
                                  //Sabahçı öğlenci ayrımı
                                  selectedSchool != null
                                      ? (selectedSchool!.shiftCount == 2)
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Expanded(
                                                  child: ListTile(
                                                    title:
                                                        const Text('Sabahçı'),
                                                    leading: Radio(
                                                      value: 0,
                                                      groupValue:
                                                          schoolStartTime,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          schoolStartTime =
                                                              value!;
                                                        });
                                                      },
                                                      activeColor: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: ListTile(
                                                    title:
                                                        const Text('Öğlenci'),
                                                    leading: Radio(
                                                      value: 1,
                                                      groupValue:
                                                          schoolStartTime,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          schoolStartTime =
                                                              value!;
                                                        });
                                                      },
                                                      activeColor: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const SizedBox()
                                      : const SizedBox(),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: ListTile(
                                          title: const Text('Tek Yön'),
                                          leading: Radio(
                                            value: false,
                                            groupValue: isTwoWay,
                                            onChanged: (value) {
                                              setState(() {
                                                isTwoWay = value!;
                                                extra = size.height * 0.06;
                                              });
                                            },
                                            activeColor: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: ListTile(
                                          title: const Text('Çift Yön'),
                                          leading: Radio(
                                            value: true,
                                            groupValue: isTwoWay,
                                            onChanged: (value) {
                                              setState(() {
                                                isTwoWay = value!;
                                                extra = 0;
                                              });
                                            },
                                            activeColor: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  //Tek yönse
                                  !isTwoWay
                                      ? Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: ListTile(
                                                title:
                                                    const Text('Evden Okula'),
                                                leading: Radio(
                                                  value: true,
                                                  groupValue: homeToSchool,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      homeToSchool = value!;
                                                    });
                                                  },
                                                  activeColor: Colors.black,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: ListTile(
                                                title:
                                                    const Text('Okuldan Eve'),
                                                leading: Radio(
                                                  value: false,
                                                  groupValue: homeToSchool,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      homeToSchool = value!;
                                                    });
                                                  },
                                                  activeColor: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                  Row(children: [
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: SizedBox(
                                          height: 70,
                                          width: double.infinity,
                                          child: TextFormField(
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 5.0,
                                                      horizontal: 10),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: COLOR_LIGHT_GREY),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: COLOR_DARK_GREY),
                                              ),
                                              hintText: 'Öğrenci Adı Soyadı',
                                              //errorText: errorText2
                                            ),
                                            controller: nameController,
                                            onFieldSubmitted: (value) {
                                              nameController.text = value;
                                            },
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Öğrenci Adı Soyadı Boş Bırakılamaz";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                                  DropdownGeneral(
                                    searchable: false,
                                    list: classList
                                        .map((element) => element.toString())
                                        .toList(),
                                    onChanged: (p0) {
                                      setState(() {
                                        selectedClass = p0;
                                      });
                                    },
                                    selectedValue: selectedClass,
                                    previewText: "Sınıf Seç",
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                          child: SizedBox(
                                        height: 70,
                                        child: PhoneField(
                                            readOnly: true,
                                            color: COLOR_BG_LIGHT,
                                            controller: parPhoneController),
                                      )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              child: Text(
                                "Veli Bilgileri",
                                style: Theme.of(context).textTheme.headline2,
                              ),
                            ),
                          ),
                        ),
                        //scrollable list
                        Column(children: [
                          Container(
                            width: size.width,
                            margin: const EdgeInsets.only(bottom: 10),
                            height: size.height * 0.23,
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10)),
                            child: FutureBuilder<Parent>(
                              future: getParentByPhone(
                                  makePhoneValidAgain(parPhoneController.text)),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(snapshot.error!.toString()),
                                  );
                                } else if (snapshot.hasData) {
                                  parNameController.text = snapshot.data!.name;
                                  addrController.text = snapshot.data!.address;
                                  return Column(children: [
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: SizedBox(
                                          height: 50,
                                          width: double.infinity,
                                          child: TextField(
                                            readOnly: true,
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 5.0,
                                                      horizontal: 10),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: COLOR_LIGHT_GREY),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: COLOR_DARK_GREY),
                                              ),
                                              hintText: 'Veli Adı Soyadı*',
                                            ),
                                            controller: parNameController,
                                            onSubmitted: (value) {
                                              parNameController.text = value;
                                            },
                                            onChanged: (value) {
                                              print(
                                                  "Now Iam become death, destroyer of worlds");
                                              parNameController.value =
                                                  parNameController.value
                                                      .copyWith(
                                                text: capitalizeFirstLetter(
                                                    value),
                                                selection: TextSelection(
                                                    baseOffset: value.length,
                                                    extentOffset: value.length),
                                                composing: TextRange.empty,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: SizedBox(
                                          height: 50,
                                          width: double.infinity,
                                          child: SizedBox(
                                            height: 70,
                                            child: PhoneField(
                                                color: COLOR_BG_LIGHT,
                                                controller: secPhoneController),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(children: [
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: SizedBox(
                                            height: 50,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.8,
                                            child: TextField(
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 5.0,
                                                        horizontal: 10),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: COLOR_LIGHT_GREY),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: COLOR_DARK_GREY),
                                                ),
                                                hintText: 'Adres*',
                                              ),
                                              controller: addrController,
                                              onSubmitted: (value) {
                                                addrController.text = value;
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                          onPressed: (() {}),
                                          icon: const Icon(Icons.map))
                                    ]),
                                  ]);
                                } else {
                                  return const Center(
                                    child: Text("..."),
                                  );
                                }
                              },
                            ),
                          ),
                        ]),
                        Column(
                          children: [
                            FinanceButton(
                              //navigate to payment list page
                              onPressed: () {
                                setState(() {});

                                if (selectedSchool == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Lütfen geçerli bir okul seçiniz!'),
                                    ),
                                  );
                                } else if (nameController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Lütfen öğrenci ismi giriniz!'),
                                    ),
                                  );
                                } else if (parPhoneController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Lütfen veli telefon numarası giriniz!'),
                                    ),
                                  );
                                } else if (addrController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Lütfen adres giriniz!'),
                                    ),
                                  );
                                } else if (selectedClass == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Lütfen geçerli bir sınıf seçiniz!'),
                                    ),
                                  );
                                }else {
                                  updateStudent(
                                      nameController.text,
                                      selectedClass!,
                                      selectedSchool!.schoolId,
                                      secPhoneController.text,
                                      addrController.text,
                                      widget.studentId,
                                      paymentwho,
                                      "String addressDirections",
                                      schoolStartTime,
                                      isTwoWay,
                                      homeToSchool);
                                }
                                //TO DO: need to check school start time is not 2(full day)
                                //in other words no radio button is selected while two devre okul is selected
                              },
                              child: Text(
                                'Güncelle',
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          )
        : const CircularProgressIndicator(
            color: Colors.black,
          );
  }

  Future<bool> isParentByPhone(String phone) async {
    var url = Uri.http(deployURL, 'user/getParentByPhone');

    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'phone': phone,
    });

    if (phone == "") {
      return Future.error("Lütfen bir telefon numarası giriniz.");
    }
    if (response.statusCode == 404) {
      return false;
    } else if (response.statusCode == 200) {
      return true;
    } else {
      return Future.error("Bir hata oluştu: ${response.body}");
    }
  }

  Future<Parent> getParentByPhone(String phone) async {
    var url = Uri.http(deployURL, 'user/getParentByPhone');

    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'phone': phone,
    });

    if (phone == "") {
      return Future.error("Lütfen bir telefon numarası giriniz.");
    }
    if (response.statusCode == 404) {
      return Future.error('Veli bulunamadı...');
    } else if (response.statusCode == 200) {
      print(response.body);
      return Parent.fromJson(jsonDecode(response.body));
    } else {
      return Future.error("Bir hata oluştu: ${response.body}");
    }
  }

  void updateStudent(
      String name,
      String stuClass,
      String schoolId,
      String secondPhone,
      String address,
      String studentID,
      PaymentWho whogondothepay,
      String addressDirections,
      int schoolStartTime,
      bool isTwoWay,
      bool homeToSchool) async {
    int directionPref = 0;

    if (stuClass == "Anasınıfı") {
      stuClass = "0";
    }

    secondPhone = makePhoneValidAgain(secondPhone);

    if (isTwoWay) {
      directionPref = 1;
    } else {
      if (homeToSchool) {
        directionPref = 2;
      } else {
        directionPref = 3;
      }
    }

    print("This is school start time");
    print(schoolStartTime);

    var url = Uri.http(deployURL, 'student/updateStudentByDriver');
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      "studentID": studentID,
      "address": address,
      "school": schoolId,
      "name": name,
      "secondPhoneNumber": secondPhone,
      "directionPreference": directionPref.toString(),
      "whogondothePayment": whogondothepay.getInt().toString(),
      "schoolStartTime": schoolStartTime.toString(),
      "class": stuClass,
    });

    print(response.body);

    if (response.statusCode != 200) {
      throw Exception(response.body);
    } else if (response.statusCode == 200) {
      final snackBar = SnackBar(
        content: const Text('Öğrenci güncellendi.'),
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

  Future<Map<String, dynamic>> getStudentInfo(String studentId) async {
    var url = Uri.http(deployURL, 'student/getStudentByDriver');

    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'phone': await getUserPhone(),
      'studentID': studentId,
    });
    print(response.body);

    String temp =
        "{\"name\": \"Ali\", \"class\": \"5\", \"schoolId\":\"6421f5e4fbdc191f98127f6d\",\"parentPhone\": \"555\"}";
    //return jsonDecode(temp);

    return jsonDecode(response.body);
  }
}
