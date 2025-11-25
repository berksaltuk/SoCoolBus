import 'package:flutter/material.dart';

import '../../components/common_methods.dart';
import '../../models/school.dart';

class SchoolAdminBusInfo extends StatefulWidget {
  const SchoolAdminBusInfo({super.key});

  @override
  State<SchoolAdminBusInfo> createState() => _SchoolAdminBusInfo();
}

class _SchoolAdminBusInfo extends State<SchoolAdminBusInfo> {
  bool _isLoaded = false;
  @override
  void initState() {
    _isLoaded = true;
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
                  title: Text("Servis Hareketleri"),
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Yapım aşamasında.",
                                    style:
                                        Theme.of(context).textTheme.headline2,
                                  ),
                                ]),
                          ),
                        )))))
        : const CircularProgressIndicator(color: Colors.black);
    ;
  }
}
