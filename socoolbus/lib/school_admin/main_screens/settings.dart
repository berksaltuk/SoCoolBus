import 'package:flutter/material.dart';

import '../../auth/login.dart';
import '../../auth/logout.dart';
import '../../components/common_methods.dart';
import '../../constants.dart';
import '../../models/school.dart';

class SchoolAdminSettings extends StatefulWidget {
  const SchoolAdminSettings({super.key});

  @override
  State<SchoolAdminSettings> createState() => _SchoolAdminSettings();
}

class _SchoolAdminSettings extends State<SchoolAdminSettings> {
  bool _isLoaded = false;
  @override
  void initState() {
    _isLoaded = true;
    super.initState();
  }

  @override
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // Create a key
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Text("Ayarlar"),
                actions: [
                  IconButton(
                    onPressed: () => {
                      logout(),
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                          (Route<dynamic> route) => false)
                    },
                    icon: Icon(
                      Icons.exit_to_app,
                      color: COLOR_DARK_GREY,
                    ),
                  ),
                ]),
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
                                style: Theme.of(context).textTheme.headline2,
                              ),
                            ]),
                      ),
                    )))));
  }
}
