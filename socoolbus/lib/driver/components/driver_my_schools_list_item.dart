import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/constants.dart';

import 'package:http/http.dart' as http;

class MySchoolsList extends StatefulWidget {
  final String name;
  final String id;
  final VoidCallback updateParent;

  const MySchoolsList(
      {super.key,
      required this.id,
      required this.name,
      required this.updateParent});

  @override
  State<MySchoolsList> createState() => _MySchoolsListState();
}

class _MySchoolsListState extends State<MySchoolsList> {
  Future<String> phone = getUserPhone();
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: Container(
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
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              elevation: 16,
                              child: Container(
                                child: ListView(
                                  shrinkWrap: true,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              '${widget.name} okulunu listenizden çıkarmak istediğinize emin misiniz?\nBu işlem geri alınamaz.',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Hayır'),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    await deleteSchoolFromMySchools(
                                                      widget.id,
                                                      phone,
                                                    ).then(
                                                      (value) =>
                                                          widget.updateParent(),
                                                    );
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Evet'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        "Çıkar",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.0,
                          color: COLOR_RED_MONEY,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Future deleteSchoolFromMySchools(
      String schoolId, Future<String> phone) async {
    String ph = await phone;
    var url = Uri.http(deployURL, 'school/removeSchoolFromDriver');
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
