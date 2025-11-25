import 'package:flutter/material.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/components/parent_bottom_navigation.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/driver/components/select_school.dart';
import 'package:my_app/models/school.dart';

import 'driver_bottom_navigation.dart';

class ChangeSchool extends StatefulWidget {
  const ChangeSchool({super.key});

  @override
  State<ChangeSchool> createState() => ChangeSchoolState();
}

class ChangeSchoolState extends State<ChangeSchool> {
  School? selectedSchool;
  bool _isLoaded = false;
  late List<School> school_list;

  @override
  initState() {
    getDriverSchools(getUserPhone()).then((value) {
      setState(() {
        school_list = value;
        _isLoaded = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String? userTypeName;
    return _isLoaded
        ? IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(builder: (context, setState) {
                      return AlertDialog(
                        title: const Text("Okul Seç"),
                        content: DropdownButtonSchool(
                          list: school_list,
                          onChanged: (p0) {
                            setState(() {
                              selectedSchool = p0;
                            });
                          },
                          selectedValue: selectedSchool,
                        ),
                        actions: [
                          TextButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(COLOR_ORANGE)),
                            onPressed: () {
                                if(selectedSchool != null){
                                    setSelectedSchool(selectedSchool!.schoolId);
                                }
                                Navigator.of(context).pop();
                            },
                            child: const Text("Seç"),
                          )
                        ],
                      );
                    });
                  });
            },
            icon: const Icon(Icons.apartment))
        : const CircularProgressIndicator(color: Colors.black);
  }
}
