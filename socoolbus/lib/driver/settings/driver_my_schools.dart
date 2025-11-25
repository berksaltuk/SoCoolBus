import 'package:flutter/material.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/driver/components/driver_school_list_item.dart';
import 'package:my_app/driver/components/finance_button.dart';
import 'package:my_app/driver/settings/driver_define_school.dart';
import 'package:my_app/models/school.dart';

import '../components/driver_my_schools_list_item.dart';
import 'driver_add2_my_schools.dart';

class DriverMySchools extends StatefulWidget {
  const DriverMySchools({super.key});

  @override
  State<DriverMySchools> createState() => _DriverMySchoolsState();
}

class _DriverMySchoolsState extends State<DriverMySchools> {
  //List<School> allSchools =
  late List<School> filteredSchools;
  late Future<List<School>> mySchools;
  //List<School> driverSchools = getDriverSchools(phone);

  @override
  void initState() {
    super.initState();
    filteredSchools = [];
    mySchools = getDriverSchools(getUserPhone());
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 20,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: COLOR_BLACK,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Okullarım',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 60,
                      child: TextButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DriverAdd2MySchools(),
                            ),
                          );
                          setState(() {
                            mySchools = getDriverSchools(getUserPhone());
                          });
                        },
                        child: const Icon(
                          Icons.add,
                          color: COLOR_BLACK,
                          size: 40,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //title
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: const Text(
                        "Ekli Okullar",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                ),
                //scrollable list
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: size.width,
                        margin: EdgeInsets.only(bottom: 10),
                        height: size.height * 0.34,
                        child: FutureBuilder<List<School>>(
                          future: mySchools,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              // Display loading screen for a second
                              return FutureBuilder(
                                future: Future.delayed(Duration(seconds: 1)),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              );
                            } else if (snapshot.hasError) {
                              return const Center(
                                child: Text('Bir hata oluştu!'),
                              );
                            } else if (!snapshot.hasData) {
                              return const Center(
                                child: Text('Eklenen okulunuz yok!'),
                              );
                            } else if (snapshot.hasData) {
                              return ListView(
                                children: [
                                  for (var school in snapshot.data!)
                                    MySchoolsList(
                                      id: school.schoolId,
                                      name: school.name,
                                      updateParent: updateState,
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateState() {
    setState(() {
      mySchools = getDriverSchools(getUserPhone());
      mySchools = mySchools.then((schools) {
        return schools;
      });
    });
  }
}
