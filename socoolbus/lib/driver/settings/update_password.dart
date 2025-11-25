import 'dart:io';
import 'package:logger/logger.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';

import 'package:my_app/components/general_button.dart';
import 'package:http/http.dart' as http;

// import 'model.dart';
var logger = Logger();

class UpdatePassword extends StatefulWidget {
  UpdatePassword({super.key});

  @override
  _UpdatePasswordState createState() => _UpdatePasswordState();
}

Future<String> getUserPhone() async {
  final SharedPreferences session = await SharedPreferences.getInstance();
  final String? phone = session.getString('phone');
  Future<String> future = Future.value(phone);
  return future;
}

class _UpdatePasswordState extends State<UpdatePassword> {
  _UpdatePasswordState();

  bool showProgress = false;
  bool visible = false;

  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController currentPwdController = TextEditingController();
  final TextEditingController newPwdController = TextEditingController();
  final TextEditingController newPwdConfirmController = TextEditingController();

  bool passwordsMatch(String value) {
    return newPwdController.text == value;
  }

  FocusNode focusNode = FocusNode();
  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  bool _isObscure = true;
  bool _isObscure2 = true;
  bool _isObscure3 = true;

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
    String userPhone = "";
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                          FutureBuilder<String>(
                            future: getUserPhone(),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.hasData) {
                                String phone = snapshot.data!;
                                userPhone = phone;
                                return CircularProgressIndicator();
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.20,
                          ),
                          Text(
                            "Şifre Değiştir",
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
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            focusNode: focusNode,
                            obscureText: _isObscure,
                            autofocus: true,
                            controller: currentPwdController,
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
                              hintText: 'Mevcut Şifre',
                              enabled: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 8.0, top: 8.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              RegExp regex = RegExp(r'^.{6,}$');
                              if (value!.isEmpty) {
                                return "Mevut şifre kısmı boş bırakılamaz!";
                              }
                              if (!regex.hasMatch(value)) {
                                return ("Lütfen en az altı karakterden oluşan geçerli bir şifre giriniz");
                              } else {
                                return null;
                              }
                            },
                            onSaved: (value) {
                              currentPwdController.text = value!;
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            focusNode: focusNode,
                            obscureText: _isObscure2,
                            autofocus: true,
                            controller: newPwdController,
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
                              hintText: 'Yeni Şifre',
                              enabled: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 8.0, top: 8.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              RegExp regex = RegExp(r'^.{6,}$');
                              if (value!.isEmpty) {
                                return "Yeni şifre kısmı boş bırakılamaz!";
                              }
                              if (!regex.hasMatch(value)) {
                                return ("Lütfen en az altı karakterden oluşan geçerli bir şifre giriniz");
                              } else {
                                return null;
                              }
                            },
                            onSaved: (value) {
                              newPwdController.text = value!;
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            focusNode: focusNode,
                            obscureText: _isObscure3,
                            autofocus: true,
                            controller: newPwdConfirmController,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  color: COLOR_DARK_GREY,
                                  icon: Icon(_isObscure3
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      _isObscure3 = !_isObscure3;
                                    });
                                  }),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Yeni Şifre Doğrula',
                              enabled: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 8.0, top: 8.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              RegExp regex = RegExp(r'^.{6,}$');
                              if (value!.isEmpty) {
                                return "Şifre doğrulama kısmı boş bırakılamaz!";
                              }
                              if (!regex.hasMatch(value)) {
                                return ("Lütfen en az altı karakterden oluşan geçerli bir şifre giriniz");
                              } else {
                                if (!passwordsMatch(value)) {
                                  return "Yeni şifreler eşleşmiyor.";
                                } else {
                                  return null;
                                }
                              }
                            },
                            onSaved: (value) {
                              newPwdConfirmController.text = value!;
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          GeneralButton(
                            onPressed: () async {
                              if (currentPwdController.text.isNotEmpty &&
                                  newPwdController.text.isNotEmpty &&
                                  newPwdConfirmController.text.isNotEmpty) {
                                //pwd is sent to user's phone, backend does most of the job about verification
                                Future<int> res = updatePassword(
                                    currentPwdController.text,
                                    newPwdController.text,
                                    newPwdConfirmController.text,
                                    userPhone);
                                int result = await res;
                                print(result);
                                if (result == 400) {
                                  final snackBar400 = SnackBar(
                                    content: const Text('Mevcut şifre yanlış'),
                                    action: SnackBarAction(
                                      label: '',
                                      onPressed: () {
                                        // Some code to undo the change.
                                      },
                                    ),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar400);
                                } else if (result == 200) {
                                  final snackBar200 = SnackBar(
                                    content: const Text('Şifre güncellendi'),
                                    action: SnackBarAction(
                                      label: '',
                                      onPressed: () {
                                        // Some code to undo the change.
                                      },
                                    ),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar200);
                                  Navigator.pop(context);
                                }
                              }
                            },
                            child: const Text(
                              "Değiştir",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
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
      ),
    );
  }

  Future<int> updatePassword(String curPassword, String newPassword,
      String newPasswordAgain, String phone) async {
    print(await getUserToken());
    var url = Uri.http(deployURL, 'user/updatePassword');
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'currentPassword': curPassword,
      'newPassword': newPassword,
      'newPasswordAgain': newPasswordAgain,
      'phone': phone,
    });

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
    return response.statusCode;
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
