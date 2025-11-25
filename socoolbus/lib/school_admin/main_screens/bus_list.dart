import 'package:flutter/material.dart';

import '../../components/common_methods.dart';
import '../../models/school.dart';

class SchoolAdminBusList extends StatefulWidget {
  const SchoolAdminBusList({super.key});

  @override
  State<SchoolAdminBusList> createState() => _SchoolAdminBusList();
}

class _SchoolAdminBusList extends State<SchoolAdminBusList> {
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
