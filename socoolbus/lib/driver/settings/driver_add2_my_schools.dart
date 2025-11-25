import 'package:flutter/material.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/driver/components/driver_school_list_item.dart';
import 'package:my_app/driver/components/finance_button.dart';
import 'package:my_app/driver/settings/driver_define_school.dart';
import 'package:my_app/driver/settings/driver_my_schools.dart';
import 'package:my_app/models/school.dart';

class DriverAdd2MySchools extends StatefulWidget {
  const DriverAdd2MySchools({super.key});

  @override
  State<DriverAdd2MySchools> createState() => _DriverAdd2MySchoolsState();
}

class _DriverAdd2MySchoolsState extends State<DriverAdd2MySchools> {
  //List<School> allSchools =
  List<School> filteredSchools = [];
  late Future<List<School>> allSchools;
  //List<School> driverSchools = getDriverSchools(phone);

  void initState() {
    super.initState();
    allSchools = getAllSchools();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          // ignore: prefer_const_constructors
          title: Text(
            'Okul Ekle',
            style: const TextStyle(fontSize: 24),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                FutureBuilder<List<School>>(
                  future: allSchools,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              width: size.width,
                              margin: EdgeInsets.symmetric(vertical: 4),
                              height: size.height * 0.72,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: size.height * 0.06,
                                    child: TextField(
                                      onChanged: searchSchool,
                                      decoration: InputDecoration(
                                          hintText: 'Okul Ara',
                                          hintStyle: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: COLOR_BLACK),
                                          border: OutlineInputBorder(),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: COLOR_DARK_GREY),
                                          )),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  filteredSchools.isEmpty
                                      ? Expanded(
                                          child: ListView(
                                          children: [
                                            for (var school in snapshot.data!)
                                              SchoolList(
                                                id: school.schoolId,
                                                city: school.address,
                                                name: school.name,
                                                status: false,
                                                updateParent: updateState,
                                              ),
                                          ],
                                        ))
                                      : Expanded(
                                          child: ListView.builder(
                                            itemCount: filteredSchools.length,
                                            itemBuilder: (context, index) {
                                              var school =
                                                  filteredSchools[index];
                                              return SchoolList(
                                                  id: school.schoolId,
                                                  city: school.address,
                                                  name: school.name,
                                                  status: false,
                                                  updateParent: updateState);
                                            },
                                          ),
                                        )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
                Column(
                  children: [
                    FinanceButton(
                      //navigate to payment list page
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DriverDefineSchool()),
                        );
                      },
                      child: Text(
                        'Okul Tanımla',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ),
                    SizedBox(height: size.height * 0.001),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Center(
                        child: Text(
                          "Çalışılan okulunuz bulunamadı ise okul tanımlayınız.",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateState() {
    setState(() {
      Future<List<School>> mySchools = getDriverSchools(getUserPhone());
      mySchools = mySchools.then((schools) {
        return schools;
      });
      Navigator.pop(
        context,
        mySchools,
      );
    });
  }

  void searchSchool(String query) async {
    final schools = await allSchools;
    final results = schools.where((school) {
      final schoolName = school.name.toLowerCase();
      final input = query.toLowerCase();
      return schoolName.contains(input);
    }).toList();
    setState(() {
      filteredSchools = results;
    });
  }
}
