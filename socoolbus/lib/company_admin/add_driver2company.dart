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
import '../models/school_bus.dart';
import 'components/company_admin_bottom_navigation.dart';
import 'components/dropdown_bus.dart';
import 'main_screens/settings.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class AddDriverToCompany extends StatefulWidget {
  const AddDriverToCompany({super.key});

  @override
  State<AddDriverToCompany> createState() => _AddDriverToCompanyState();
}

class _AddDriverToCompanyState extends State<AddDriverToCompany> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController tcController = TextEditingController();
  TextEditingController plateController = TextEditingController();
  bool _isLoaded = false;
  late Future<List<SchoolBus>> allBuses;
  late Future<String> userPhone;
  SchoolBus? selectedBus;

  @override
  void initState() {
    userPhone = getUserPhone();
    //allBuses = getCompanyBuses(userPhone);
    _isLoaded = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Şoför Ekle"),
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
                  controller: nameController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Ad Soyad',
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
                  inputFormatters: [TurkishPhoneNumberFormatter()],
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Telefon',
                    enabled: true,
                    contentPadding:
                        EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Telefon numarası boş girilemez";
                    }

                    if (isvalidPhoneNumber(value)) {
                      return "Lütfen Geçerli Bir Telefon Numarası Giriniz";
                    }
                  },
                  onChanged: (value) {},
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: tcController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'TC Kimlik No',
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
                _isLoaded
                    ? FutureBuilder<List<SchoolBus>>(
                        future: getCompanyBuses(userPhone),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text('Bir hata oluştu!'),
                            );
                          } else if (!snapshot.hasData) {
                            return const Center(
                                child: SizedBox(
                                    height: 52,
                                    child: LinearProgressIndicator(
                                      color: COLOR_GREY,
                                    )) //Text('Eklenen okulunuz yok!'),
                                );
                          } else if (snapshot.hasData) {
                            return DropdownButtonSchoolBus(
                              list: snapshot.data!,
                              //width: MediaQuery.of(context).size.width * 0.70,
                              onChanged: (p0) {
                                setState(() {
                                  setSelectedSchool(p0!.schoolBusId);
                                  selectedBus = p0;
                                });
                              },
                              selectedValue: selectedBus,
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      )
                    : const CircularProgressIndicator(
                        color: Colors.black,
                      ),
                FinanceButton(
                    onPressed: () {
                      addDriver(phoneController.text, nameController.text,
                          tcController.text, selectedBus!.schoolBusId);
                    },
                    child: Text("Şoför Ekle"))
              ],
            )),
      ),
    );
  }

  Future<List<SchoolBus>> getCompanyBuses(Future<String> phone) async {
    var url = Uri.http(deployURL, 'companyAdmin/getSchoolBusesList');
    var ph = await phone;
    var phoney = makePhoneValidAgain(ph);

    logger.i(url);
    final response = await http.post(url, headers: {
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

  void addDriver(String phone, String name, String tc, String busID) async {
    var url =
        Uri.http(deployURL, 'companyAdmin/addDriverToSchoolBusByCompanyAdmin');
    var role = "DRIVER";
    var phoney = makePhoneValidAgain(phone);
    logger.i(url);
    final response = await http.post(url, headers: {
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'name': name,
      'phone': phoney,
      'role': role,
      'schoolBusID': busID,
      'tcno': tc,
    });

    logger.i(response.body);

    if (response.body == "{\"errors\":[{\"msg\":\"User already exists\"}]}") {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Hesap Yaratılamadı"),
              content: Text("Bu telefona kayıtlı bir hesap var."),
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
        content: const Text('Şoför başarıyla yaratıldı!'),
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
