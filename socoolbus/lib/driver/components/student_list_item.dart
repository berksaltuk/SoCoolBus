import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_app/driver/sub_students/update_student.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:http/http.dart' as http;
import '../../components/common_methods.dart';
import '../../constants.dart';

class StudentList extends StatelessWidget {
  StudentList(
      {super.key,
      required this.studentId,
      required this.name,
      required this.phone,
      required this.address,
      required this.editable,
      required this.index,
      required this.updateParent});

  final String studentId;
  final String name;
  final String phone;
  final String address;
  final int index;
  bool editable;
  final VoidCallback updateParent;

  late var phoneUri = Uri.parse("tel:+90$phone");
  late var addressUri = Uri.parse(address);

  @override
  Widget build(BuildContext context) {
    var latlon = address.substring(
      address.lastIndexOf('=') + 1,
    );
    var la = latlon.substring(0, latlon.indexOf(","));
    var lo = latlon.substring(
      latlon.indexOf(",") + 1,
    );

    double lat = double.parse(la);
    double lon = double.parse(lo);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                Text(
                  (index + 1).toString(), // To show indexes start from 1
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
            editable
                ? Row(
                    children: [
                      Container(
                        width: 40,
                        child: const InkWell(
                            onTap: null,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.format_line_spacing_rounded,
                                color: COLOR_BLACK,
                                size: 30,
                              ),
                            )),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: InkWell(
                          onTap: () async {
                            if (await canLaunchUrl(phoneUri)) {
                              launchUrl(phoneUri);
                            } else {
                              throw 'Could not launch $phoneUri';
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: ImageIcon(
                              AssetImage('assets/icons/phone.png'),
                              color: Colors.black,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: InkWell(
                          onTap: () async {
                            try {
                              final coords = Coords(lat, lon);
                              final title = "$name isimli öğrencinin adresi";
                              final availableMaps =
                                  await MapLauncher.installedMaps;
                              print(availableMaps);
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return SafeArea(
                                    child: SingleChildScrollView(
                                      child: Container(
                                        child: Wrap(
                                          children: <Widget>[
                                            for (var map in availableMaps)
                                              ListTile(
                                                onTap: () => map.showMarker(
                                                  coords: coords,
                                                  title: title,
                                                ),
                                                title: Text(map.mapName),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            } catch (e) {
                              print(e);
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: ImageIcon(
                              AssetImage('assets/icons/location.png'),
                              color: Colors.black,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: InkWell(
                          onTap: () async {
                            await showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                  elevation: 16,
                                  child: Container(
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: <Widget>[
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            children: [
                                              Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '$name isimli öğrenci için işlemler',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton(
                                                        onPressed: () {
                                                          print(
                                                              "updateStudent");
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  DriverUpdateStudent(
                                                                      studentId:
                                                                          studentId),
                                                            ),
                                                          );
                                                        },
                                                        child: const Text(
                                                            'Güncelle')),
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  Expanded(
                                                    child: ElevatedButton(
                                                        onPressed: () async {
                                                          await showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return Dialog(
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            4)),
                                                                elevation: 16,
                                                                child:
                                                                    Container(
                                                                  child:
                                                                      ListView(
                                                                    shrinkWrap:
                                                                        true,
                                                                    children: <
                                                                        Widget>[
                                                                      Container(
                                                                        padding:
                                                                            const EdgeInsets.all(20),
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Align(
                                                                              alignment: Alignment.centerLeft,
                                                                              child: Text(
                                                                                '$name isimli öğrenciyi silmek istediğinize emin misiniz?',
                                                                                style: Theme.of(context).textTheme.titleMedium,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 10,
                                                                            ),
                                                                            Row(
                                                                              children: [
                                                                                Expanded(
                                                                                  child: ElevatedButton(
                                                                                      onPressed: () {
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      child: const Text('Hayır')),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 20,
                                                                                ),
                                                                                Expanded(
                                                                                  child: ElevatedButton(
                                                                                      onPressed: () async {
                                                                                        await deleteStudent(studentId).then(
                                                                                          (value) => updateParent(),
                                                                                        );
                                                                                        Navigator.pop(context);
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      child: const Text('Evet')),
                                                                                ),
                                                                              ],
                                                                            )
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
                                                        child:
                                                            const Text('Sil')),
                                                  ),
                                                ],
                                              )
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
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.more_vert,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
          ],
        ),
      ]),
    );
  }

  Future<void> deleteStudent(String studentId) async {
    var url = Uri.http(deployURL, 'student/deleteStudentByDriver');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'studentID': studentId
    });
    print(response.body);
  }
}
