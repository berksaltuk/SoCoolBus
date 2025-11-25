import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/constants.dart';

import 'package:http/http.dart' as http;

class SchoolList extends StatefulWidget {
  final String name;
  final String city;
  final bool status;
  final String id;
  final VoidCallback updateParent;

  const SchoolList(
      {super.key,
      required this.id,
      required this.name,
      required this.city,
      required this.status,
      required this.updateParent});

  @override
  State<SchoolList> createState() => _SchoolListState();
}

class _SchoolListState extends State<SchoolList> {
  @override
  Widget build(BuildContext context) {
    Future<String> phone = getUserPhone();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6), color: COLOR_WHITE),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                flex: 4,
                child: Column(
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.name,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins'),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.city,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Poppins'),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: SizedBox(
                  child: TextButton(
                    onPressed: () async {
                      await addSchoolToMySchools(
                        widget.id,
                        phone,
                      ).then(
                        (value) => widget.updateParent(),
                      );
                    },
                    child: Text(
                      "Ekle",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.0,
                        color: COLOR_GREEN_MONEY,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Future addSchoolToMySchools(String schoolId, Future<String> phone) async {
    String ph = await phone;
    var url = Uri.http(deployURL, 'school/addSchoolToDriver');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'phone': ph,
      'school_id': schoolId
    });
    print(response.body);
  }
}
