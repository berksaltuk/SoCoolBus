import 'dart:convert';
import 'dart:io';

import 'package:my_app/components/common_methods.dart' as cm;
import 'components/update_password.dart';
import 'package:flutter/material.dart';
import 'package:my_app/auth/login.dart';
import 'package:my_app/auth/logout.dart';
import 'package:my_app/components/general_button.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/models/student.dart';
import 'package:my_app/components/select_child.dart';
import 'package:my_app/models/student_setting.dart';
import 'package:my_app/parent/parent_addr_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ParentSettingsScreen extends StatefulWidget {
  const ParentSettingsScreen({super.key});

  @override
  State<ParentSettingsScreen> createState() => _ParentSettingsState();
}

class _ParentSettingsState extends State<ParentSettingsScreen> {
  Student? _selectedStudent;
  late Future<List<Student>> stuList;
  String? _name;
  String? _address;
  String? _phone;
  bool _isLoaded = false;
  bool appNotification = false;
  bool callNotification = false;
  final TextEditingController secondPhoneController = TextEditingController();
  final TextEditingController schoolNameController = TextEditingController();
  final TextEditingController classController = TextEditingController();

  @override
  void initState() {
    stuList = cm.getParentChildren(getUserPhone());
    SharedPreferences.getInstance().then((value) => {
          _name = value.getString("name"),
          _phone = value.getString("phone"),
          _address = "",
          stuList.then((value) => {
                _selectedStudent = value.first,
                getStudentSetting(_selectedStudent, true).then((value) => {
                      secondPhoneController.text =
                          "İkinci Telefon: ${value.secondPhone}",
                      schoolNameController.text = "Okul: ${value.schoolName}",
                      classController.text =
                          "Sınıf:  ${value.stuClass.toString()}",
                      appNotification = value.notificationPreference,
                      callNotification = value.callPreference,
                      setState(() {
                        _isLoaded = true;
                      })
                    }),
              }),
        });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoaded
        ? Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Image.asset("assets/images/sy_logo.jpeg",
                    fit: BoxFit.contain),
                onPressed: () => {},
              ),
              title: const Text("Ayarlar"),
              actions: [
                IconButton(
                    onPressed: (() {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => UpdatePassword()),
                          (Route<dynamic> route) => false);
                      logout();
                    }),
                    icon: const Icon(Icons.password_sharp, color: Colors.red)),
                IconButton(
                    onPressed: (() {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                          (Route<dynamic> route) => false);
                      logout();
                    }),
                    icon: const Icon(Icons.logout, color: Colors.red))
              ],
            ),
            body: Container(
              margin: const EdgeInsets.all(8),
              child: ListView(children: [
                const Text(
                  "\t\tVeli Bilgileri",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  initialValue: _name,
                  readOnly: true,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: _name,
                    enabled: true,
                    contentPadding: const EdgeInsets.only(
                        left: 14.0, bottom: 0.0, top: 8.0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  initialValue: _phone,
                  readOnly: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: _phone,
                    enabled: true,
                    contentPadding: const EdgeInsets.only(
                        left: 14.0, bottom: 0.0, top: 8.0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  initialValue: _address,
                  readOnly: true,
                  style: const TextStyle(height: 1),
                  maxLines: 4,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    enabled: true,
                    hintText: _address,
                    contentPadding: const EdgeInsets.only(
                        left: 14.0, bottom: 0.0, top: 8.0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.55,
                    ),
                    MaterialButton(
                        color: const Color.fromARGB(1, 205, 205, 205),
                        onPressed: (() => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ParentAddrSettings()),
                              )
                            }),
                        child: Row(
                          children: const [
                            Icon(Icons.location_pin),
                            Text(
                              "Adres Değiştir",
                              textAlign: TextAlign.center,
                            )
                          ],
                        ))
                  ],
                ),

                // Student Info
                const Text(
                  "\t\tÖğrenci Bilgileri",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(
                  height: 10,
                ),
                FutureBuilder<List<Student>>(
                  future: stuList,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Bir hata oluştu!${snapshot.error}'),
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
                ),
                const SizedBox(
                  height: 10,
                ),
                FutureBuilder<StudentSetting>(
                  future: getStudentSetting(_selectedStudent, false),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Bir hata oluştu!${snapshot.error}'),
                      );
                    } else if (snapshot.hasData) {
                        classController.text = "Sınıf: ${snapshot.data!.stuClass == 0 ? "Anasınıfı" : snapshot.data!.stuClass.toString()}";
                      return Column(
                        children: [
                          TextFormField(
                            controller: schoolNameController,
                            readOnly: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color.fromARGB(40, 44, 36, 36),
                              hintText: snapshot.data!.schoolName,
                              enabled: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 0.0, top: 8.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: secondPhoneController,
                            readOnly: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText:
                                  "İkinci Telefon: ${snapshot.data!.secondPhone}",
                              enabled: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 0.0, top: 8.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: classController,
                            readOnly: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              enabled: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 0.0, top: 8.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 8,
                              ),
                              const Text(
                                "Uygulama Bildirimi",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.39,
                              ),
                              Switch(
                                  value: appNotification,
                                  activeColor: Colors.grey,
                                  onChanged: ((value) {
                                    setState(() {
                                      appNotification = value;
                                    });
                                  }))
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 8,
                              ),
                              const Text(
                                "Çağrı Tercihi",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.51,
                              ),
                              Switch(
                                  value: callNotification,
                                  activeColor: Colors.grey,
                                  onChanged: ((value) {
                                    setState(() {
                                      callNotification = value;
                                    });
                                  }))
                            ],
                          ),
                        ],
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
                      width: MediaQuery.of(context).size.width * 0.38,
                    ),
                    GeneralButton(
                        onPressed: () {
                          setStudentSetting(_selectedStudent, callNotification,
                              appNotification);
                        },
                        child: const Text(
                          "Kaydet",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.32,
                    ),
                  ],
                ),
              ]),
            ))
        : const Center(child: CircularProgressIndicator(color: Colors.black));
  }

  Future<StudentSetting> getStudentSetting(
      Student? selectedStudent, bool changeRadioButton) async {
    var url = Uri.http(deployURL, 'student/getStudentSettings');
    print(url);

    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await cm.getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'studentID': selectedStudent!.studentId,
    });
    print(response.body);
    final parsed = jsonDecode(response.body);
    StudentSetting settings = StudentSetting.fromJson(parsed);
    secondPhoneController.text = "İkinci Telefon: ${settings.secondPhone}";
    schoolNameController.text = "Okul: ${settings.schoolName}";
    classController.text = "Sınıf:  ${settings.stuClass.toString()}";
    if (changeRadioButton) {
      appNotification = settings.notificationPreference;
      callNotification = settings.callPreference;
    }
    return settings;
  }

  void setStudentSetting(Student? selectedStudent, bool callNotification,
      bool appNotification) async {
    var url = Uri.http(deployURL, 'student/updateStudentSettings');
    print(url);

    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await cm.getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'studentID': selectedStudent!.studentId,
      "secondPhone": selectedStudent.secondPhone,
      "smsPreference": "false",
      "notificationPreference": appNotification.toString(),
      "callPreference": callNotification.toString()
    });
    print(response.body);
    if (response.statusCode == 200) {
      final snackBar = SnackBar(
        content: const Text('Ayarlar kaydedildi.'),
        action: SnackBarAction(
          label: '',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}     
        
        /*SettingsList(
            lightTheme: const SettingsThemeData(
                settingsListBackground: Color.fromARGB(250, 242, 247, 255)),
            darkTheme: const SettingsThemeData(
                settingsListBackground: Color.fromARGB(250, 242, 247, 255)),
            sections: [
              CustomSettingsSection(
                  child: Column(
                children: const <Widget>[
                  Text("Murat Karaoğlu", style: TextStyle(fontSize: 26)),
                  Text("555-555-5555", style: TextStyle(fontSize: 18)),
                  Text("", style: TextStyle(fontSize: 18))
                ],
              )),
              SettingsSection(
                  title: const Text(
                    "General",
                    style: TextStyle(fontSize: 16),
                  ),
                  tiles: <SettingsTile>[
                    SettingsTile.navigation(
                      title: const Text("Kişisel Bilgiler"),
                      value: const Text("Telefon, E-mail vb."),
                      leading: const Icon(Icons.person),
                      onPressed: (context) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const PersonalInfoSettings()),
                        );
                      },
                    ),
                    SettingsTile.navigation(
                      title: const Text("Çocuk Bilgileri"),
                      value: const Text("Çocuk Telefonu"),
                      leading: const Icon(Icons.child_care),
                      onPressed: (context) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChildInfoSettings()),
                        );
                      },
                    ),
                    SettingsTile.navigation(
                      title: const Text("Adres"),
                      value: const Text(""),
                      leading: const Icon(Icons.map),
                      onPressed: (context) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ParentAddrSettings()),
                        );
                      },
                    ),
                    SettingsTile.navigation(
                      title: const Text("Dil"),
                      value: const Text(""),
                      leading: const Icon(Icons.language),
                      onPressed: (context) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ParentLangSettings()),
                        );
                      },
                    ),
                  ]),
              SettingsSection(
                  title: const Text(
                    "Bildirim Ayarları",
                    style: TextStyle(fontSize: 16),
                  ),
                  tiles: <SettingsTile>[
                    SettingsTile.switchTile(
                      initialValue: false,
                      title: const Text("Uygulama Bildirimi"),
                      leading: const Icon(Icons.notifications),
                      onToggle: ((value) => {}),
                    ),
                    SettingsTile.switchTile(
                      initialValue: true,
                      title: const Text("Çağrı Tercihi"),
                      leading: const Icon(Icons.phone),
                      onToggle: ((value) => {}),
                    ),
                  ])
            ]),
      );*/

