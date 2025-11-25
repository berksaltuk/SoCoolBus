import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_app/company_admin/main_screens/home_screen.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/components/parent_bottom_navigation.dart';
import 'package:my_app/components/select_general.dart';
import 'package:my_app/constants.dart';

import 'driver_bottom_navigation.dart';

class ChangeUser extends StatefulWidget {
  final List<String> userTypesTR;

  const ChangeUser({super.key, required this.userTypesTR});

  @override
  State<ChangeUser> createState() => ChangeUserState();
}

class ChangeUserState extends State<ChangeUser> {
  String? dropdownValue;

  @override
  Widget build(BuildContext context) {
    String? userTypeName;
    return IconButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(builder: (context, setState) {
                  return AlertDialog(
                    title: const Text("Kullanıcı Tipi Seç"),
                    content: DropdownGeneral(
                      list: widget.userTypesTR,
                      onChanged: (p0) {
                        setState(() {
                          userTypeName = p0 as String;
                        });
                      },
                      selectedValue: userTypeName,
                      searchable: false,
                    ),
                    actions: [
                      TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(COLOR_ORANGE)),
                        onPressed: () {
                          if (userTypeName == "Veli") {
                            switchUserType(userTypeName!);
                            Timer(const Duration(seconds: 1), () {
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ParentNavigation(),
                                ),
                              );
                            });
                          } else if (userTypeName == "Sürücü") {
                            switchUserType(userTypeName!);
                            Timer(const Duration(seconds: 1), () {
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DriverNavigation(),
                                ),
                              );
                            });
                          }else if (userTypeName == "Şirket İdarecisi") {
                            switchUserType(userTypeName!);
                            Timer(const Duration(seconds: 1), () {
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CompanyAdminHomeScreen(),
                                ),
                              );
                            });
                          }else if (userTypeName == "Okul İdarecisi") {
                            switchUserType(userTypeName!);
                            Timer(const Duration(seconds: 1), () {

                                /*
                                Burda da buna benzeyen bir mantık olması gerekiyor
                                okul idaresi bittikten sonra
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DriverNavigation(),
                                ),
                              );*/
                            });
                          }
                        },
                        child: const Text("Değiştir"),
                      )
                    ],
                  );
                });
              });
        },
        icon: const Icon(Icons.supervised_user_circle));
  }
}
