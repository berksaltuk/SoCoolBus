import 'package:flutter/material.dart';
import 'package:my_app/components/change_user.dart';
import 'package:my_app/components/common_methods.dart';

class CompanyAdminHomeScreen extends StatefulWidget {
  const CompanyAdminHomeScreen({super.key});

  @override
  State<CompanyAdminHomeScreen> createState() => _CompanyAdminHomeScreen();
}

class _CompanyAdminHomeScreen extends State<CompanyAdminHomeScreen> {
  bool _isLoaded = false;
  final List<String> _userTypes = [];
  final List<String> _userTypesTR = [];
  @override
  void initState() {
    getUserTypes().then((value1) {
      for (String i in value1) {
        if (i == "DRIVER") {
          _userTypesTR.add("Sürücü");
        } else if (i == "PARENT") {
          _userTypesTR.add("Veli");
        } else if (i == "COMPANY_ADMIN") {
          _userTypesTR.add("Şirket İdarecisi");
        } else if (i == "SCHOOL_ADMINISTRATOR") {
          _userTypesTR.add("Okul İdarecisi");
        }
      }
      _isLoaded = true;
    });

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
                  title: Text("Kurumsal Yönetici Anasayfa"),
                  automaticallyImplyLeading: false,
                  actions: [
                    _userTypes.length > 1
                        ? ChangeUser(userTypesTR: _userTypesTR)
                        : const SizedBox()
                  ],
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
