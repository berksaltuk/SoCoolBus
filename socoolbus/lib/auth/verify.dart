import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/components/common_methods.dart';
import '../components/phone_formatter.dart';
import '../constants.dart';
import 'forgot.dart';
import 'login.dart';
import 'package:my_app/components/general_button.dart';
import 'package:http/http.dart' as http;

// import 'model.dart';
var logger = Logger();

class Verify extends StatefulWidget {
  final String phone;
  Verify({super.key, required this.phone});

  @override
  _VerifyState createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  _VerifyState();

  bool showProgress = false;
  bool visible = false;

  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController codeController = TextEditingController();

  FocusNode focusNode = FocusNode();
  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  bool _isObscure = true;
  bool _isObscure2 = true;
  File? file;
  //db de büyük harf sorun çıkartabilir!!
  var options = ['Sürücü', 'İdari', 'Veli'];
  var _currentItemSelected = "Veli";
  var role = "Veli";

  bool isvalidPhoneNumber(String phoneNumber) {
    final RegExp phoneRegex = RegExp(
      r'^(\+?90)?( )?\d{3}( )?\d{3}( )?\d{2}( )?\d{2}$',
      caseSensitive: false,
      multiLine: false,
    );
    return !phoneRegex.hasMatch(phoneNumber);
  }

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

  @override
  Widget build(BuildContext context) {
    String phone = widget.phone;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white10,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(12),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.20,
                        ),
                        Text(
                          "SMS Doğrula",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 28,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          focusNode: focusNode,
                          autofocus: true,
                          controller: codeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Doğrulama Kodu',
                            enabled: true,
                            contentPadding: const EdgeInsets.only(
                                left: 14.0, bottom: 8.0, top: 8.0),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Doğrulama kodu boş olamaz.";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            codeController.text = value!;
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        GeneralButton(
                          onPressed: () {
                            if (codeController.text.isNotEmpty) {
                              //const CircularProgressIndicator();
                              final snackBar = SnackBar(
                                content: Text(
                                    'Doğrulama kodu sistemle eşlişirse yeni şifreniz SMS yoluyla ulaştırılacak.'),
                                action: SnackBarAction(
                                  label: '',
                                  onPressed: () {
                                    // Some code to undo the change.
                                  },
                                ),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                              );

                              //pwd is sent to user's phone, backend does most of the job about verification
                              sendNewPassword(phone, codeController.text);
                            }
                          },
                          child: const Text(
                            "Doğrula",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void signUp(String name, String phone, String password, String role) async {
    var url = Uri.http(deployURL, 'user/signup');
    if (role == "Veli") {
      role = "PARENT";
    } else if (role == "İdari") {
      role = "ADMIN";
    } else {
      role = "DRIVER";
    }
    logger.i(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'name': name,
      'phone': phone,
      'password': password,
      'role': role,
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

  void sendNewPassword(String phone, String code) async {
    var url = Uri.http(deployURL, 'user/forgetPassword');
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'phone': phone,
      'forgetPasswordCode': code,
    });

    if (response.statusCode != 200) {
      throw Exception(response.body);
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
}
