import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:my_app/auth/forgot.dart';
import 'package:my_app/auth/terms.dart';
import '../components/phone_field.dart';
import '../constants.dart';
import 'login.dart';
import 'package:my_app/components/general_button.dart';
import 'package:http/http.dart' as http;
import '../components/phone_formatter.dart';
import 'package:logger/logger.dart';
import '../components/plate_formatter.dart';

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

bool isValidTCNumber(String input) {
  if (input.length != 11) {
    return false;
  }
  int tc1 = (input[0].codeUnitAt(0) -
          48 +
          input[2].codeUnitAt(0) -
          48 +
          input[4].codeUnitAt(0) -
          48 +
          input[6].codeUnitAt(0) -
          48 +
          input[8].codeUnitAt(0) -
          48) *
      7;
  int tc2 = (input[1].codeUnitAt(0) -
          48 +
          input[3].codeUnitAt(0) -
          48 +
          input[5].codeUnitAt(0) -
          48 +
          input[7].codeUnitAt(0) -
          48) *
      9;
  int tcA = (tc1 + tc2) % 10;
  int tcB = (tc1 ~/ 7);
  tcB = ((tcB * 8) % 10);

  if ((input[9].codeUnitAt(0) - 48) == tcA &&
      (input[10].codeUnitAt(0) - 48) == tcB) {
    return true;
  } else {
    return false;
  }
}

class SignUpDriver extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<SignUpDriver> {
  _RegisterState();

  bool showProgress = false;
  bool visible = false;

  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpassController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController plateController = TextEditingController();
  final TextEditingController tcController = TextEditingController();

  bool _isObscure = true;
  bool _isObscure2 = true;
  File? file;
  //db de büyük harf sorun çıkartabilir!!
  //var options = ['Sürücü', 'İdari', 'Veli'];
  //var _currentItemSelected = "Veli";
  //var role = "Veli";

  bool agree = false;

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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "Ücretsiz hesap oluşturun",
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
                            "15 gün boyunca tüm özellikleri ücretsiz deneyin",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
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
                            controller: plateController,
                            inputFormatters: [
                              //TurkishPlateNumberFormatter(),
                              LengthLimitingTextInputFormatter(10)
                            ],
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Plaka',
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
                            controller: tcController,
                            validator: (value) {
                              return (value!.length < 11 && value.isNotEmpty)
                                  ? 'TC Kimlik Numarası 11 hane olmalı'
                                  : null;
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(11),
                            ],
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'TC Kimlik No',
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
                            color: COLOR_WHITE,
                            controller: phoneController,
                          ),
                          /* TextFormField(
                            inputFormatters: [
                              TurkishPhoneNumberFormatter(),
                              LengthLimitingTextInputFormatter(15)
                            ],
                            controller: phoneController,
                            keyboardType: TextInputType.number,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Telefon',
                              enabled: true,
                              contentPadding: EdgeInsets.only(
                                  left: 14.0, bottom: 8.0, top: 8.0),
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
                          ), */
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            obscureText: _isObscure,
                            controller: passwordController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
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
                                borderSide: BorderSide(color: COLOR_WHITE),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: COLOR_WHITE),
                              ),
                            ),
                            validator: (value) {
                              RegExp regex = RegExp(r'^.{6,}$');
                              if (value!.isEmpty) {
                                return "Şifre boş bırakılamaz";
                              }
                              if (!regex.hasMatch(value)) {
                                return ("Şifre 6 haneden uzun olmalı ");
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
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
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
                                return "Şifreler uyuşmuyor";
                              } else {
                                return null;
                              }
                            },
                            onChanged: (value) {},
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          /* Row(
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
                                dropdownColor: Colors.white70,
                                isDense: true,
                                isExpanded: false,
                                iconEnabledColor: Colors.black,
                                focusColor: Colors.black,
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
                          ), */
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              /* GeneralButton(
                                child: Text("buton"),
                                onPressed: () {
                                  setState(() {
                                    showProgress = true;
                                  });
                                  if (passwordController.text ==
                                      confirmpassController.text) {
                                    signUp(
                                        nameController.text,
                                        phoneController.text,
                                        passwordController.text,
                                        plateController.text,
                                        tcController.text);
                                  } else {
                                    final snackBar = SnackBar(
                                      content: const Text('Şifreler eşleşmedi!'),
                                      action: SnackBarAction(
                                        label: '',
                                        onPressed: () {},
                                      ),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  }
                                },
                              ), */
                              Material(
                                color: COLOR_BG_LIGHT,
                                child: Checkbox(
                                  value: agree,
                                  hoverColor: COLOR_BLACK,
                                  focusColor: COLOR_BLUE_MONEY,
                                  checkColor: COLOR_WHITE,
                                  fillColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                    return COLOR_ORANGE;
                                  }),
                                  onChanged: (value) {
                                    setState(() {
                                      agree = value ?? false;
                                    });
                                  },
                                ),
                              ),
                              /* Flexible(
                                child: const Text(
                                  'KVKK metnini okudum ve kişisel verilerimin işlenmesini kabul ediyorum',
                                  //overflow: TextOverflow.ellipsis,
                                ),
                              ), */
                              Flexible(
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                      child: Text.rich(TextSpan(
                                          text:
                                              'Kişisel verilerimin işlenmesine ',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black),
                                          children: <TextSpan>[
                                        TextSpan(
                                            text: 'KVKK',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        Terms(),
                                                  ),
                                                );
                                              }),
                                        TextSpan(
                                          text:
                                              ' metni kapsamında izin veriyorum.',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black),
                                        )
                                      ]))),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: GeneralButton(
                              onPressed: () {
                                if (agree &&
                                    isValidTCNumber(tcController.text)) {
                                  setState(() {
                                    showProgress = true;
                                  });
                                  signUp(
                                      nameController.text,
                                      phoneController.text,
                                      passwordController.text,
                                      plateController.text,
                                      tcController.text);
                                } else if (!agree) {
                                  final snackBar = SnackBar(
                                    content: const Text(
                                        'KVKK metnini kabul ediniz.'),
                                    action: SnackBarAction(
                                      label: '',
                                      onPressed: () {
                                        // Some code to undo the change.
                                      },
                                    ),
                                  );

                                  // Find the ScaffoldMessenger in the widget tree
                                  // and use it to show a SnackBar.
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                } else if (confirmpassController.text !=
                                    passwordController.text) {
                                  final snackBar = SnackBar(
                                    content:
                                        const Text('Şifreleriniz eşleşmiyor.'),
                                    action: SnackBarAction(
                                      label: '',
                                      onPressed: () {
                                        // Some code to undo the change.
                                      },
                                    ),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                } else if (!isValidTCNumber(
                                    tcController.text)) {
                                  final snackBar = SnackBar(
                                    content: const Text(
                                        'Geçerli bir TC Kimlik No giriniz.'),
                                    action: SnackBarAction(
                                      label: '',
                                      onPressed: () {
                                        // Some code to undo the change.
                                      },
                                    ),
                                  );

                                  // Find the ScaffoldMessenger in the widget tree
                                  // and use it to show a SnackBar.
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              },
                              child: const Text(
                                "Ücretsiz Hesap Oluştur",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
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
                                fontSize: 20,
                              ),
                            ),
                          ),
                          /* SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: GeneralButton(
                              onPressed: () {
                                //const CircularProgressIndicator();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Mevcut hesabınıza Giriş Yapın",
                                style:
                                    TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ), */
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

  void signUp(String name, String phone, String password, String plate,
      String tc) async {
    var url = Uri.http(deployURL, 'user/signup');
/*     if (role == "Veli") {
      role = "PARENT";
    } else if (role == "İdari") {
      role = "ADMIN";
    } else {
      role = "DRIVER";
    } */
    var role = "DRIVER";
    var phoney = makePhoneValidAgain(phone);
    logger.i(url);
    final response = await http.post(url, headers: {
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'name': name,
      'phone': phoney,
      'password': password,
      'role': role,
      'plate': plate,
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

/*
  void signUp(String email, String password, String role) async {
    CircularProgressIndicator();
    if (_formkey.currentState!.validate()) {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {postDetailsToFirestore(email, role)})
          .catchError((e) {});
    }
  }
*/
/*   postDetailsToFirestore(String email, String role) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var user = _auth.currentUser;
    if (role == "Veli") {
      role = "PARENT";
    } else if (role == "İdari") {
      role = "ADMIN";
    } else {
      role = "DRIVER";
    }
    CollectionReference ref = FirebaseFirestore.instance.collection('users');
    ref.doc(user!.uid).set({'email': phoneController.text, 'role': role});
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  } */
}
