import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/components/select_general.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/driver/components/expense_list_item.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/models/expense.dart';

import '../auth/login.dart';
import '../components/phone_formatter.dart';
import '../driver/components/finance_button.dart';
import 'components/company_admin_bottom_navigation.dart';
import 'main_screens/settings.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class AddBusToCompany extends StatefulWidget {
  const AddBusToCompany({super.key});

  @override
  State<AddBusToCompany> createState() => _AddBusToCompanyState();
}

class _AddBusToCompanyState extends State<AddBusToCompany> {
  TextEditingController seatCountController = TextEditingController();
  TextEditingController plateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Araç Ekle"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: plateController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Plaka',
                    enabled: true,
                    contentPadding:
                        EdgeInsets.only(left: 14.0, bottom: 8.0, top: 15.0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  onChanged: (value) {},
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: seatCountController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Koltuk Sayısı',
                    enabled: true,
                    contentPadding:
                        EdgeInsets.only(left: 14.0, bottom: 8.0, top: 15.0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  onChanged: (value) {},
                ),
                const SizedBox(
                  height: 20,
                ),
                FinanceButton(
                    onPressed: () {
                      addBus(plateController.text, seatCountController.text);
                    },
                    child: Text("Araç Ekle"))
              ],
            )),
      ),
    );
  }

  void addBus(String plate, String seatCount) async {
    var url = Uri.http(deployURL, 'companyAdmin/addSchoolBusByCompanyAdmin');
    logger.i(url);
    final response = await http.post(url, headers: {
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'companyAdminPhone': await getUserPhone(),
      'plate': plate,
      'seatCount': seatCount
    });

    logger.i(response.body);

    if (response.body ==
        "{\"errors\":[{\"msg\":\"School bus exists with that plate.\"}]}") {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Araç Yaratılamadı"),
              content: Text("Bu plakaya kayıtlı bir araç var."),
              actions: [
                MaterialButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
      //snackbar display when user creation is successful, then route to sign in, complete
    } else {
      final snackBar = SnackBar(
        content: const Text('Araç başarıyla yaratıldı!'),
        action: SnackBarAction(
          label: '',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );

      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CompanyAdminNavigation(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
