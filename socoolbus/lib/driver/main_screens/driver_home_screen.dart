import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/components/change_user.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/components/select_general.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/driver/components/driver_home_agenda.dart';
import 'package:my_app/driver/components/finance_button.dart';
import 'package:my_app/driver/components/select_school.dart';
import 'package:my_app/driver/settings/settings_drawerMenu.dart';
import 'package:my_app/driver/sub_home/driver_start_shift_screen.dart';
import 'package:my_app/models/agenda_entry.dart';
import 'package:my_app/models/school.dart';
import 'package:http/http.dart' as http;

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHomeScreen> {
  School? selectedSchool;
  String? shiftName;
  String? userTypeName;
  List<String> _userTypes = [];
  final List<String> _userTypesTR = [];
  bool _isLoaded = false;

  @override
  void initState() {
    getUserTypes().then((valueUserType) {
      for (String i in valueUserType) {
        if (i == "DRIVER") {
          _userTypesTR.add("Sürücü");
        } else if (i == "PARENT") {
          _userTypesTR.add("Veli");
        } else if (i == "COMPANY_ADMIN") {
          _userTypesTR.add("Şirket İdarecisi");
        } else if (i == "SCHOOL_ADMINISTRATOR") {
          _userTypesTR.add("Okul İdarecisi");
        }
      }
      getDriverSchools(getUserPhone()).then(
        (value) async {
          if (value.isEmpty) {
            setState(() {
              _userTypes = valueUserType;
              _isLoaded = true;
            });
          } else if ((await getSelectedSchool()) == null) {
            setSelectedSchool(value.first.schoolId);
            selectedSchool = value.first;
            setState(() {
              _userTypes = valueUserType;
              _isLoaded = true;
            });
          } else {
            findSchoolById((await getSelectedSchool())!).then((value) {
              selectedSchool = value;
              setState(() {
                _userTypes = valueUserType;
                _isLoaded = true;
              });
            }).onError(((error, stackTrace) {
              setState(() {
                _userTypes = valueUserType;
                _isLoaded = true;
              });
            }));
          }
        },
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key
    return _isLoaded
        ? WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
                key: _key,
                drawer: const DriverSettings(),
                appBar: AppBar(
                  leading: SizedBox(
                    width: 40,
                    child: TextButton(
                      onPressed: () {
                        _key.currentState!.openDrawer();
                      },
                      child: const Icon(
                        Icons.settings,
                        color: COLOR_BLACK,
                        size: 40,
                      ),
                    ),
                  ),
                  title: const Center(
                    child: Text(
                      'Anasayfa',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  actions: [
                    _userTypes.length > 1
                        ? ChangeUser(userTypesTR: _userTypesTR)
                        : const SizedBox(
                            width: 40,
                          )
                  ],
                  automaticallyImplyLeading: false,
                ),
                body: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //Agenda column.
                      Column(
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
                                    child: SizedBox(
                                        height: 52,
                                        child: LinearProgressIndicator(
                                          color: COLOR_GREY,
                                        )) //Text('Eklenen okulunuz yok!'),
                                    );
                              } else if (snapshot.hasData) {
                                if (snapshot.data!.isEmpty) {
                                  return const Text('Eklenen okulunuz yok!');
                                }
                                return DropdownButtonSchool(
                                  list: snapshot.data!,
                                  //width: MediaQuery.of(context).size.width * 0.70,
                                  previewText: "Okul Seç",
                                  searchText: "Okul Ara",
                                  onChanged: (p0) {
                                    setState(() {
                                      setSelectedSchool(p0!.schoolId);
                                      selectedSchool = p0;
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
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: const Text(
                                "Gündem",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          Container(
                            height: size.height * 0.42,
                            child: FutureBuilder<List<AgandaEntry>>(
                              future: getAgandaEntries(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                        'Bir hata oluştu!\n${snapshot.error!.toString()}'),
                                  );
                                } else if (snapshot.hasData) {
                                  if (snapshot.data!.isEmpty) {
                                    return const Center(
                                      child: Text('Gösterilecek gündem yok!'),
                                    );
                                  }
                                  return ListView(
                                    children: [
                                      for (var entry in snapshot.data!)
                                        DriverHomeAgenda(
                                            title: entry.mainHeader,
                                            description: DateFormat("dd/MM")
                                                .format(entry.date)
                                                .toString(),
                                            source: entry.description,
                                            status: entry.summary),
                                    ],
                                  );
                                } else {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      //Start ride column.
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: const Text(
                                "Sürüş",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          Container(
                              width: size.width,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  /*const SizedBox(
                              height: 10,
                            ),*/
                                  // This is the button for automatic shift selecetion
                                  /*
                            FinanceButton(
                              onPressed: (() {
                                if (selectedSchool == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Servise başlamak için okul seçiniz!'),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DriverStartShift(
                                          shiftID:
                                              createShift(selectedSchool!)),
                                    ),
                                  );
                                }
                              }),
                              child: Text(
                                'Servise Başla',
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            ),*/
                                  FinanceButton(
                                    onPressed: (() {
                                      if (selectedSchool == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Servise başlamak için okul seçiniz!'),
                                          ),
                                        );
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return StatefulBuilder(
                                                  builder: (context, setState) {
                                                return AlertDialog(
                                                  title: Text(
                                                      "${selectedSchool!.name} Sürüşü Başlat"),
                                                  content: selectedSchool!
                                                              .shiftCount ==
                                                          2
                                                      ? DropdownGeneral(
                                                          list: const [
                                                            "Sabah Giriş",
                                                            "Öğlen Çıkış",
                                                            "Öğlen Giriş",
                                                            "Akşam Çıkış"
                                                          ],
                                                          onChanged: (p0) {
                                                            setState(() {
                                                              shiftName =
                                                                  p0 as String;
                                                            });
                                                          },
                                                          selectedValue:
                                                              shiftName,
                                                          searchable: false,
                                                        )
                                                      : DropdownGeneral(
                                                          list: const [
                                                            "Sabah Giriş",
                                                            "Akşam Çıkış"
                                                          ],
                                                          onChanged: (p0) {
                                                            setState(() {
                                                              shiftName =
                                                                  p0 as String;
                                                            });
                                                          },
                                                          selectedValue:
                                                              shiftName,
                                                          searchable: false,
                                                        ),
                                                  actions: [
                                                    TextButton(
                                                      style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(
                                                                      COLOR_ORANGE)),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => DriverStartShift(
                                                                schoolName:
                                                                    selectedSchool!
                                                                        .toString(),
                                                                shiftID: createShift(
                                                                    selectedSchool!,
                                                                    shiftName!)),
                                                          ),
                                                        );
                                                      },
                                                      child:
                                                          const Text("Başlat"),
                                                    )
                                                  ],
                                                );
                                              });
                                            });
                                      }
                                    }),
                                    child: Text(
                                      'Servise Başla',
                                      style:
                                          Theme.of(context).textTheme.headline3,
                                    ),
                                  )
                                ],
                              ))
                        ],
                      ),
                    ],
                  ),
                )),
          )
        : const Center(child: CircularProgressIndicator(color: Colors.black));
  }

  Future<String> createShift(School school, String shiftName) async {
    var url = Uri.http(deployURL, 'shift/createShift');
    print(url);

    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'driverPhone': await getUserPhone(),
      'schoolID': school.schoolId,
      'shiftName': shiftName,
    });

    print(response.body);

    var jsonResponse = jsonDecode(response.body);

    return jsonResponse['shiftID'];
  }

  Future<List<AgandaEntry>> getAgandaEntries() async {
    var url = Uri.http(deployURL, 'driver/getAgendaEntries');
    print(url);

    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'driverPhone': await getUserPhone(),
    });
    print(response.body);
    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    return parsed
        .map<AgandaEntry>((json) => AgandaEntry.fromJson(json))
        .toList();
  }
}
