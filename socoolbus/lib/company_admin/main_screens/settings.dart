import 'package:flutter/material.dart';
import 'package:my_app/driver/components/finance_button.dart';

import '../../auth/login.dart';
import '../../auth/logout.dart';
import '../../constants.dart';
import '../add_bus2company.dart';
import '../add_driver2company.dart';

class CompanyAdminSettings extends StatefulWidget {
  const CompanyAdminSettings({super.key});

  @override
  State<CompanyAdminSettings> createState() => _CompanyAdminSettings();
}

class _CompanyAdminSettings extends State<CompanyAdminSettings> {
  bool _isLoaded = false;
  @override
  void initState() {
    _isLoaded = true;
    super.initState();
  }

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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FinanceButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AddDriverToCompany()),
                                  );
                                },
                                child: Text(
                                  "Şoför Ekle",
                                  style: Theme.of(context).textTheme.headline1,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              FinanceButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AddBusToCompany()),
                                  );
                                },
                                child: Text(
                                  "Araç Ekle",
                                  style: Theme.of(context).textTheme.headline1,
                                ),
                              )
                            ]),
                      ),
                    )))));
  }
}
