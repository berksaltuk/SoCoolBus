import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/driver/components/finance_button.dart';
import 'package:my_app/driver/settings/settings_drawerMenu.dart';
import 'package:my_app/driver/sub_profile/driver_profile_documents.dart';
import 'package:my_app/driver/sub_profile/profile_edit_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<String> getUserName() async {
  final SharedPreferences session = await SharedPreferences.getInstance();
  final String? name = session.getString('name');
  Future<String> future = Future.value(name);
  return future;
}

Future<String> getUserPhone() async {
  final SharedPreferences session = await SharedPreferences.getInstance();
  final String? phone = session.getString('phone');
  Future<String> future = Future.value(phone);
  return future;
}

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileState();
}

class _DriverProfileState extends State<DriverProfileScreen> {
  final TextEditingController nameCont = TextEditingController();
  final TextEditingController phoneCont = TextEditingController();
  final TextEditingController plateCont = TextEditingController();
  final TextEditingController modelCont = TextEditingController();
  final TextEditingController seatCont = TextEditingController();
  final TextEditingController muayeneCont = TextEditingController();
  final TextEditingController sigortaCont = TextEditingController();

  bool _isLoaded = false;

  @override
  initState() {
    getUserName().then((value) {
      nameCont.text = value;
    });

    getUserPhone().then((value) {
      phoneCont.text = value;
    });

    getSchoolBus().then((value) {
      plateCont.text = value['plate'] ?? "Plaka yok";
      modelCont.text = value['busModel'] ?? "Model yok";
      seatCont.text = value['seatCount'].toString();
      if (value['muayeneEnds'] != null) {
        muayeneCont.text = DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(value['muayeneEnds']));
      } else {
        muayeneCont.text = "Muayene Tarihi Yok";
      }

      if (value['sigortaEnds'] != null) {
        sigortaCont.text = DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(value['sigortaEnds']));
      } else {
        sigortaCont.text = "Sigorta Tarihi Yok";
      }

      setState(() {
        _isLoaded = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final GlobalKey<ScaffoldState> _key = GlobalKey();
    return _isLoaded
        ? WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
                key: _key,
                drawer: DriverSettings(),
                appBar: AppBar(
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Profil',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 60,
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
                          )
                        ],
                      ),
                    ],
                  ),
                  automaticallyImplyLeading: false,
                ),
                body: FutureBuilder<SharedPreferences>(
                    future: SharedPreferences.getInstance(),
                    builder: (context, snapshot) => Container(
                        margin: EdgeInsets.all(15),
                        child: ListView(children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "\t\tProfil Bilgileri",
                            style: TextStyle(fontSize: 16, color: COLOR_BLACK),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            //initialValue: snapshot.data?.getString('name'),
                            controller: nameCont,
                            //TextEditingController(text: snapshot.data?.getString('name')),
                            readOnly: true,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "Ad Soyad",
                              //hintText: snapshot.data?.getString('name'),
                              labelStyle: const TextStyle(color: Colors.black),
                              enabled: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 0.0, top: 8.0),
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
                            //initialValue: snapshot.data?.getString("phone"),
                            controller: phoneCont,
                            //TextEditingController(text: snapshot.data?.getString('phone')),
                            readOnly: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "Telefon",
                              labelStyle: TextStyle(color: Colors.black),
                              enabled: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 0.0, top: 8.0),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Flexible(
                                child: Text(
                                  "\t\tAraç Bilgileri",
                                  style: TextStyle(
                                      fontSize: 16, color: COLOR_BLACK),
                                ),
                              ),
                              IconButton(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ProfileEditPage()),
                                    );
                                    initState();
                                  },
                                  icon: Icon(Icons.edit)),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: plateCont,
                            readOnly: true,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "Araç Plakası",
                              labelStyle: const TextStyle(color: Colors.black),
                              enabled: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 0.0, top: 8.0),
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
                            controller: modelCont,
                            readOnly: true,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "Araç Modeli",
                              labelStyle: const TextStyle(color: Colors.black),
                              enabled: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 0.0, top: 8.0),
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
                            controller: seatCont,
                            readOnly: true,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "Yolcu Kapasitesi",
                              labelStyle: const TextStyle(color: Colors.black),
                              enabled: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 0.0, top: 8.0),
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
                            controller: muayeneCont,
                            readOnly: true,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "Muayene Geçerlilik Tarihi",
                              labelStyle: const TextStyle(color: Colors.black),
                              enabled: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 0.0, top: 8.0),
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
                            controller: sigortaCont,
                            readOnly: true,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "Trafik Sigortası Geçerlilik Tarihi",
                              labelStyle: const TextStyle(color: Colors.black),
                              enabled: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 0.0, top: 8.0),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          FinanceButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ProfileDocumentsPage()),
                              );
                            },
                            child: Text(
                              'Evraklarım',
                              style: Theme.of(context).textTheme.headline3,
                            ),
                          ),
                        ])))))
        : const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
  }

  Future<dynamic> getSchoolBus() async {
    var url = Uri.http(deployURL, 'driver/getSchoolBusByDriver');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'phone': await getUserPhone()
    });
    print(response.body);

    final parsed = jsonDecode(response.body);
    return parsed;
  }
}
