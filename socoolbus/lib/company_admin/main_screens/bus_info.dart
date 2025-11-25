import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:my_app/company_admin/components/just_schoolbus.dart';

import '../../auth/login.dart';
import '../../components/common_methods.dart';
import '../../constants.dart';
import '../../models/school_bus.dart';
import '../components/schoolbus_list_item.dart';
import 'package:http/http.dart' as http;

var logger = Logger();

class CompanyAdminBusInfo extends StatefulWidget {
  const CompanyAdminBusInfo({super.key});

  @override
  State<CompanyAdminBusInfo> createState() => _CompanyAdminBusInfo();
}

class _CompanyAdminBusInfo extends State<CompanyAdminBusInfo> {
  bool _isLoaded = false;

  //late Future<List<SchoolBus>> allBuses;
  late String userPhone;
  late Future<List<SchoolBus>> allBuses;
  late List<SchoolBus> allBusesList;
  late int busCount;
  SchoolBus? selectedBus;

  @override
  void initState() {
    getUserPhone().then((value) async {
      userPhone = value;
      allBuses = getCompanyBuses(userPhone);
      allBusesList = await allBuses;
      busCount = allBusesList.length;
      setState(() {
        _isLoaded = true;
      });
    });
    //allBuses = getCompanyBuses(userPhone);

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
                appBar: AppBar(
                  title: Text("Servis Listesi"),
                  automaticallyImplyLeading: false,
                ),
                body: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Align(
                            alignment: Alignment.center,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Toplam Şoför Sayısı: ${busCount}",
                                      style:
                                          Theme.of(context).textTheme.headline1,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    height: size.height * 0.70,
                                    child: FutureBuilder<List<SchoolBus>>(
                                      future: allBuses,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return Center(
                                            child: Text(
                                                'Bir hata oluştu!\n${snapshot.error!.toString()}'),
                                          );
                                        } else if (snapshot.hasData) {
                                          if (snapshot.data!.isEmpty) {
                                            return const Center(
                                              child: Text(
                                                  'Gösterilecek servis yok!'),
                                            );
                                          }
                                          return ListView(
                                            children: [
                                              for (var entry in snapshot.data!)
                                                SchoolBuses(
                                                    plate: entry.plate,
                                                    name: entry.name,
                                                    phone: entry.phone),
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
                                ]),
                          ),
                        )))))
        : const Center(child: CircularProgressIndicator(color: Colors.black));
    ;
  }

  Future<List<SchoolBus>> getCompanyBuses(String phone) async {
    var url = Uri.http(deployURL, 'companyAdmin/getSchoolBusesList');
    var ph = phone;
    var phoney = makePhoneValidAgain(ph);

    logger.i(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'phone': phoney
    });
    logger.i(response.body);

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<SchoolBus>((json) => SchoolBus.fromJson(json)).toList();
  }
}
