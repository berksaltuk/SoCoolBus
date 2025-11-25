import 'package:flutter/material.dart';

class CompanyAdminStudentsInfo extends StatefulWidget {
  const CompanyAdminStudentsInfo({super.key});

  @override
  State<CompanyAdminStudentsInfo> createState() => _CompanyAdminStudentsInfo();
}

class _CompanyAdminStudentsInfo extends State<CompanyAdminStudentsInfo> {
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
                  automaticallyImplyLeading: false,
                  title: Text("Öğrenci Hareketleri"),
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
