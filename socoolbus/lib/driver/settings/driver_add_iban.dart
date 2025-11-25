import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/driver/components/driver_iban_item.dart';
import 'package:my_app/driver/components/driver_school_list_item.dart';
import 'package:my_app/driver/components/finance_button.dart';
import 'package:my_app/driver/settings/driver_define_school.dart';
import 'package:my_app/models/school.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import '../../models/account.dart';

class DriverAddIBAN extends StatefulWidget {
  const DriverAddIBAN({super.key});

  @override
  State<DriverAddIBAN> createState() => _DriverAddIBANState();
}

bool isValidIBANnumber(var input) {
  String regexPattern =
      r'\b[A-Z]{2}[0-9]{2}(?:[ ]?[0-9]{4}){5}(?!(?:[ ]?[0-9]){3})(?:[ ]?[0-9]{1,2})?\b';
  //modified https://stackoverflow.com/questions/44656264/iban-regex-design a bit to match 5 times

  RegExp regex = RegExp(regexPattern);
  bool isMatch = regex.hasMatch(input);

  return isMatch;
}

class _DriverAddIBANState extends State<DriverAddIBAN> {
  //List<School> allSchools =

  //List<School> driverSchools = getDriverSchools(phone);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          // ignore: prefer_const_constructors
          title: Text(
            'IBAN Bilgilerim',
            style: const TextStyle(fontSize: 24),
          ),
        ),
        body: ListView(children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              child: FutureBuilder<List<Account>>(
                future: getAccountsByDriver(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Bağlantıyı kontrol ediniz.");
                  } else if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                              child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            child: Center(
                              child: Text(
                                "Hesabınızda ekli IBAN bulunmamaktadır! Artı butonuna tıklayarak ekleyebilirsiniz.",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ))
                        ],
                      );
                    }
                    return Column(
                      children: [
                        for (var account in snapshot.data!)
                          IBANitem(
                              accountId: account.accountId,
                              title: account.accountName,
                              bank: account.bankName,
                              holder: account.receiver,
                              iban: account.iban),
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
          ),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await showAddDialog(context);
          },
          backgroundColor: COLOR_ORANGE,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> showAddDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          final TextEditingController accountNameController =
              TextEditingController();
          final TextEditingController bankNameController =
              TextEditingController();
          final TextEditingController receiverController =
              TextEditingController();
          final TextEditingController ibanController = TextEditingController();

          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Yeni IBAN Ekle"),
                  Form(
                      child: Column(
                    children: [
                      TextFormField(
                        controller: accountNameController,
                        validator: (value) {
                          return value!.isNotEmpty ? null : "Invalid Field";
                        },
                        decoration:
                            const InputDecoration(hintText: "Hesap Adı"),
                      ),
                      TextFormField(
                        controller: bankNameController,
                        validator: (value) {
                          return value!.isNotEmpty ? null : "Invalid Field";
                        },
                        decoration:
                            const InputDecoration(hintText: "Banka Adı"),
                      ),
                      TextFormField(
                        controller: receiverController,
                        validator: (value) {
                          return value!.isNotEmpty ? null : "Invalid Field";
                        },
                        decoration: const InputDecoration(hintText: "Ad Soyad"),
                      ),
                      TextFormField(
                        textCapitalization: TextCapitalization.characters,
                        //initialValue: "TR",
                        inputFormatters: [
                          //LengthLimitingTextInputFormatter(26),
                          MaskedInputFormatter(
                              "##00 0000 0000 0000 0000 0000 00",
                              allowedCharMatcher: RegExp(r'[A-Z]+'))
                        ],
                        controller: ibanController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (!isValidIBANnumber(value)) {
                            return "Lütfen geçerli bir iban giriniz!";
                          }
                        },
                        decoration: const InputDecoration(hintText: "IBAN"),
                      ),
                    ],
                  ))
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                  style: TextButton.styleFrom(
                      primary: COLOR_WHITE,
                      backgroundColor: COLOR_ORANGE // Text Color
                      ),
                  child: const Text(
                    "Ekle",
                  ),
                  onPressed: () async {
                    await addAccount(
                        accountNameController.text,
                        bankNameController.text,
                        receiverController.text,
                        ibanController.text);
                    setState(() {});
                  }),
            ],
          );
        });
  }

  Future<void> addAccount(
      String accountName, String bankName, String receiver, String iban) async {
    var url = Uri.http(deployURL, 'driver/addAccount');
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'accountName': accountName,
      'bankName': bankName,
      'receiver': receiver,
      'iban': iban,
      'phone': await getUserPhone()
    });

    if (response.statusCode != 200) {
      throw Exception(response.body);
    } else if (response.statusCode == 200) {
      final snackBar = SnackBar(
        content: const Text('IBAN eklendi.'),
        action: SnackBarAction(
          label: '',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      Navigator.pop(context);
    }
  }
}
