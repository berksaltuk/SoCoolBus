import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:my_app/components/select_general.dart';
import '../components/common_methods.dart';
import '../components/phone_field.dart';
import '../constants.dart';
import '../driver/components/select_school.dart';
import '../models/school.dart';
import 'login.dart';
import 'package:my_app/components/general_button.dart';
import 'package:http/http.dart' as http;
import '../components/phone_formatter.dart';
import 'package:logger/logger.dart';

import 'package:flutter/services.dart'; // text form field char limit

var logger = Logger();

String makePhoneValidAgain(String inputString) {
  if (inputString.length < 3) {
    return inputString;
  }

  if (inputString.substring(0, 3) == "+90") {
    // check if first three characters match "+90"
    inputString = inputString.substring(3);
  }

  inputString = inputString.replaceAll(' ', '');

  return inputString;
}

class SignUpAdmin extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<SignUpAdmin> {
  _RegisterState();

  bool showProgress = false;
  bool visible = false;

  final _formkey = GlobalKey<FormState>();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpassController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController schoolNameController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController companyTokenController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  School? selectedSchool;

  bool _isObscure = true;
  bool _isObscure2 = true;
  File? file;
  //db de büyük harf sorun çıkartabilir!!
  var options = ['İdari', 'Kurumsal'];
  var _currentItemSelected = "Kurumsal";
  var role = "Kurumsal";
  String selectedCity = "Gaziantep";

  late Future<List<School>> allSchools;

  @override
  void initState() {
    // TODO: implement initState
    allSchools = getAllSchools();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: COLOR_BLACK),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white10,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "Yönetici Hesabı Oluşturun",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "İdari özellikler ücretsizdir.\nKurumsal özellikleri 15 gün boyunca ücretsiz deneyin",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (role == 'Kurumsal')
                            Column(
                              children: [
                                TextFormField(
                                  controller: companyTokenController,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: 'Şirket Anahtar Kodu',
                                    enabled: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 14.0, bottom: 8.0, top: 15.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  onChanged: (value) {},
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: const SizedBox(
                                    height: 20,
                                    child: Text(
                                      "ya da",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    TextFormField(
                                      controller: companyNameController,
                                      decoration: const InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText: 'Şirket Adı',
                                        enabled: true,
                                        contentPadding: EdgeInsets.only(
                                            left: 14.0, bottom: 8.0, top: 15.0),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                      ),
                                      onChanged: (value) {},
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    DropdownGeneral(
                                      list: cityList,
                                      searchable: true,
                                      width: MediaQuery.of(context).size.width,
                                      previewText: "Şehir Seç",
                                      searchText: "Şehir Ara",
                                      onChanged: (p0) {
                                        setState(() {
                                          selectedCity = p0 as String;
                                        });
                                      },
                                      selectedValue: selectedCity,
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          if (role == "İdari")
                            Column(
                              children: [
                                FutureBuilder<List<School>>(
                                  future: allSchools,
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
                                      return DropdownButtonSchool(
                                        list: snapshot.data!,
                                        //width: MediaQuery.of(context).size.width * 0.70,
                                        previewText: "Okul Seç",
                                        searchText: "Okul Ara",
                                        onChanged: (p0) {
                                          setState(() {
                                            setSelectedSchool(p0!.schoolId);
                                            selectedSchool = p0;
                                          });
                                        },
                                        selectedValue: selectedSchool,
                                      );
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Ad Soyad',
                              enabled: true,
                              contentPadding: EdgeInsets.only(
                                  left: 14.0, bottom: 8.0, top: 15.0),
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
                            controller: titleController,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Görev',
                              enabled: true,
                              contentPadding: EdgeInsets.only(
                                  left: 14.0, bottom: 8.0, top: 15.0),
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
                          PhoneField(
                              color: COLOR_WHITE, controller: phoneController),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            obscureText: _isObscure,
                            controller: passwordController,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  color: COLOR_DARK_GREY,
                                  icon: Icon(_isObscure
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      _isObscure = !_isObscure;
                                    });
                                  }),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Şifre',
                              enabled: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 8.0, top: 15.0),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            validator: (value) {
                              RegExp regex = RegExp(r'^.{6,}$');
                              if (value!.isEmpty) {
                                return "Password cannot be empty";
                              }
                              if (!regex.hasMatch(value)) {
                                return ("please enter valid password min. 6 character");
                              } else {
                                return null;
                              }
                            },
                            onChanged: (value) {},
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            obscureText: _isObscure2,
                            controller: confirmpassController,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  color: COLOR_DARK_GREY,
                                  icon: Icon(_isObscure2
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      _isObscure2 = !_isObscure2;
                                    });
                                  }),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Şifre tekrarı',
                              enabled: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 8.0, top: 15.0),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            validator: (value) {
                              if (confirmpassController.text !=
                                  passwordController.text) {
                                return "Password did not match";
                              } else {
                                return null;
                              }
                            },
                            onChanged: (value) {},
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Hesap türü: ",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              DropdownButton<String>(
                                dropdownColor: COLOR_LIGHT_GREY,
                                isDense: true,
                                isExpanded: false,
                                iconEnabledColor: COLOR_BLACK,
                                focusColor: COLOR_BLACK,
                                items: options.map((String dropDownStringItem) {
                                  return DropdownMenuItem<String>(
                                    value: dropDownStringItem,
                                    child: Text(
                                      dropDownStringItem,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValueSelected) {
                                  setState(() {
                                    _currentItemSelected = newValueSelected!;
                                    role = newValueSelected;
                                  });
                                },
                                value: _currentItemSelected,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "Hesabınızı oluşturarak Kullanım Koşullarını kabul etmiş olursunuz.",
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GeneralButton(
                                onPressed: () {
                                  setState(() {
                                    showProgress = true;
                                  });
                                  if (passwordController.text !=
                                      confirmpassController.text) {
                                    final snackBar = SnackBar(
                                      content:
                                          const Text('Şifreler eşleşmedi!'),
                                      action: SnackBarAction(
                                        label: '',
                                        onPressed: () {},
                                      ),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                    return;
                                  }
                                  if (_currentItemSelected == "İdari") {
                                    signUp(
                                        nameController.text,
                                        phoneController.text,
                                        passwordController.text,
                                        titleController.text,
                                        schoolId: selectedSchool!.schoolId);
                                  } else {
                                    if (companyTokenController.text == "") {
                                      signUp(
                                        nameController.text,
                                        phoneController.text,
                                        passwordController.text,
                                        titleController.text,
                                        companyName: companyNameController.text,
                                        city: selectedCity,
                                      );
                                    } else {
                                      signUp(
                                        nameController.text,
                                        phoneController.text,
                                        passwordController.text,
                                        titleController.text,
                                        companyToken:
                                            companyTokenController.text,
                                      );
                                    }
                                  }
                                },
                                child: const Text(
                                  "Yönetici Hesabı Oluştur",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Mevcut hesabınıza giriş yapın",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 50,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isvalidPhoneNumber(String phoneNumber) {
    final RegExp phoneRegex = RegExp(
      r'^(\+?90)?( )?\d{3}( )?\d{3}( )?\d{2}( )?\d{2}$',
      caseSensitive: false,
      multiLine: false,
    );
    return !phoneRegex.hasMatch(phoneNumber);
  }

  void signUp(String name, String phone, String password, String title,
      {String schoolId = "yok",
      String companyToken = "yok",
      String companyName = "yok",
      String city = "yok"}) async {
    var url = Uri.http(deployURL, 'user/signup');
    var phoney = makePhoneValidAgain(phone);
    logger.i(url);

    final Response response;

    if (role == "İdari") {
      role = "SCHOOL_ADMINISTRATOR";
      response = await http.post(url, headers: {
        "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
      }, body: {
        'name': name,
        'phone': phoney,
        'password': password,
        'role': role,
        'title': title,
        'school': schoolId,
      });
      logger.i(response.body);
    } else {
      role = "COMPANY_ADMIN";
      if (companyToken == "yok") {
        response = await http.post(url, headers: {
          "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
        }, body: {
          'name': name,
          'phone': phoney,
          'password': password,
          'role': role,
          'title': title,
          'companyName': companyName,
          'city': city,
          'whoAddedCompanyPhone': phoney
        });
        logger.i(response.body);
      } else {
        response = await http.post(url, headers: {
          "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
        }, body: {
          'name': name,
          'phone': phoney,
          'password': password,
          'role': role,
          'title': title,
          'companyToken': companyToken
        });
        logger.i(response.body);
      }
    }

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
        content: const Text('Hesap başarıyla yaratıldı!'),
        action: SnackBarAction(
          label: '',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );

      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    }
  }
}
