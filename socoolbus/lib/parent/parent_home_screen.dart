import 'dart:async';
import 'dart:convert';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_app/components/change_user.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/models/location.dart';
import 'package:my_app/models/parent_dailyflow.dart';
import '../components/tappable_card.dart';
import 'package:http/http.dart' as http;
import 'components/parent_report_item.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<List<ParentDailyFlow>> getTopParentDailyFlowEntries() async {
  var url = Uri.http(deployURL, 'parent/getTopParentDailyFlowEntries');
  print(url);
  final response = await http.post(url, headers: {
    HttpHeaders.authorizationHeader: await getUserToken(),
    "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
  }, body: {
    'parentPhone': await getUserPhone()
  });
  print(response.body);

  final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
  return parsed
      .map<ParentDailyFlow>((json) => ParentDailyFlow.fromJson(json))
      .toList();
}

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeState();
}

class _ParentHomeState extends State<ParentHomeScreen> {
  List<String> _userTypes = [];
  final List<String> _userTypesTR = [];
  bool _isLoaded = false;
  var _timer;
  List<Marker> _markers = [];
  List<LatLng> _locations = [
    const LatLng(37.065943, 37.377958), // Antep
  ];

  @override
  void initState() {
    getUserTypes().then((value1) {
      for (String i in value1) {
        if (i == "DRIVER") {
          _userTypesTR.add("Sürücü");
        } else if (i == "PARENT") {
          _userTypesTR.add("Veli");
        }else if (i == "COMPANY_ADMIN") {
          _userTypesTR.add("Şirket İdarecisi");
        }else if (i == "SCHOOL_ADMINISTRATOR") {
          _userTypesTR.add("Okul İdarecisi");
        }
      }
      getLocation().then((value2) {
        getLocationLoop();
        setState(() {
          _userTypes = value1;
          _isLoaded = true;
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    GoogleMapController _mapController;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon:
                Image.asset("assets/images/sy_logo.jpeg", fit: BoxFit.contain),
            onPressed: () => {},
          ),
          title: const Text('Anasayfa'),
          actions: [
            _userTypes.length > 1
                ? ChangeUser(userTypesTR: _userTypesTR)
                : const SizedBox()
          ],
        ),
        body: ListView(
          children: [
            Container(
                width: MediaQuery.of(context).size.width * 0.95,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Gündem",
                        style: TextStyle(fontWeight: FontWeight.bold,
                                          fontSize: 30),
                        textAlign: TextAlign.start,
                      ),
                      SingleChildScrollView(
                        child: Container(
                          width: size.width,
                          margin: const EdgeInsets.only(bottom: 10),
                          height: size.height * 0.25,
                          child: FutureBuilder<List<ParentDailyFlow>>(
                            future: getTopParentDailyFlowEntries(),
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
                                    for (var dailyFlow in snapshot.data!)
                                      ParentReportItem(
                                          mainHeader: dailyFlow.mainHeader,
                                          studentName: dailyFlow.studentName,
                                          summary: dailyFlow.summary,
                                          detailedDescription:
                                              dailyFlow.detailedDescription,
                                          dateof: dailyFlow.time),
                                  ],
                                  
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.black),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ])),
            const IconButton(
                onPressed: null, icon: Icon(Icons.more_horiz_rounded)),
            const Divider(
              color: Colors.grey,
            ),
            Text(
              "Ödeme",
              style: Theme.of(context).textTheme.headline1,
              textAlign: TextAlign.center,
            ),
            tappable_card(
                onTap: (() => {}),
                month: "Kasım",
                name: "Çağatay",
                status: "Yapılmadı",
                delayStatus: "3 Gün"),
            const SizedBox(
              height: 5,
            ),
            tappable_card(
                onTap: (() => {}),
                month: "Kasım",
                name: "Ali",
                status: "Yapıldı",
                delayStatus: "Teşekkürler"),
            const IconButton(
                onPressed: null, icon: Icon(Icons.more_horiz_rounded)),
            const Divider(
              color: Colors.grey,
            ),
            Text(
              "Harita",
              style: Theme.of(context).textTheme.headline1,
              textAlign: TextAlign.center,
            ),
            Container(
              height: size.height * 0.3,
              width: size.width,
              child: GoogleMap(
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: _locations[0],
                  zoom: 13.0,
                ),
                markers: _markers.toSet(),
              ),
            ),
          ],
        ));
  }

  Future<List<Location>> getLocation() async {
    var url = Uri.http(deployURL, 'location/getLocation');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'parentPhone': await getUserPhone()
    });
    print(response.body);

    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    var map = parsed.map<Location>((json) => Location.fromJson(json)).toList();
    setState(() {
      _markers.clear();
      for (Location vehicle in map) {
        final marker = Marker(
          markerId: MarkerId(vehicle.studentID),
          position: LatLng(vehicle.lat, vehicle.lon),
          infoWindow: InfoWindow(
            title: vehicle.name,
            snippet: "Son güncelleme: ${vehicle.lastUpdate}",
          ),
        );
        _markers.add(marker);
      }
      print(_markers);
    });
    return map;
  }

  void getLocationLoop() async {
    var url = Uri.http(deployURL, 'location/getLocation');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'parentPhone': await getUserPhone()
    });
    print(response.body);

    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    var map = parsed.map<Location>((json) => Location.fromJson(json)).toList();
    setState(() {
      _markers.clear();
      if (map.isEmpty) {
        _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
          getLocationLoop();
        });
      } else {
        _locations = map;
        _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
          getLocationLoop();
        });
      }
      for (Location vehicle in map) {
        final marker = Marker(
          markerId: MarkerId(vehicle.studentID),
          position: LatLng(vehicle.lat, vehicle.lon),
          infoWindow: InfoWindow(
            title: vehicle.name,
            snippet: "Son güncelleme: ${vehicle.lastUpdate}",
          ),
        );
        _markers.add(marker);
      }
      print(_markers);
    });
  }
}
