import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/auth/verify.dart';
import 'package:my_app/components/common_methods.dart';
import '../components/phone_field.dart';
import '../components/phone_formatter.dart';
import '../constants.dart';
import 'package:my_app/components/general_button.dart';
import 'package:http/http.dart' as http;

// import 'model.dart';
var logger = Logger();
final String phone = "";
late var phoneUri = Uri.parse("tel:+90$phone");

class Forgot extends StatefulWidget {
  const Forgot({super.key});

  @override
  _ForgotState createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  _ForgotState();

  bool showProgress = false;
  bool visible = false;

  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController telephoneController = TextEditingController();

  FocusNode focusNode = FocusNode();
  String phone = "";
  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  bool _isObscure = true;
  bool _isObscure2 = true;

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
                    margin: EdgeInsets.all(12),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 60,
                          ),
                          Text(
                            "Şifremi unuttum",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 28,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          PhoneField(
                              color: COLOR_WHITE,
                              controller: telephoneController),
                          /*                         TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            inputFormatters: [TurkishPhoneNumberFormatter()],
                            focusNode: focusNode,
                            autofocus: true,
                            controller: telephoneController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Telefon',
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
                                return "Telefon numarası boş girilemez";
                              }
            
                              if (isvalidPhoneNumber(value)) {
                                return "Lütfen Geçerli Bir Telefon Numarası Giriniz";
                              }
                            },
                            onSaved: (value) {
                              telephoneController.text = value!;
                              phone = telephoneController.text;
                            },
                          ), */
                          SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Sisteme kayıtlı 10 haneli telefon numaranızı girin.\nYeni şifre SMS doğrulamasından sonra iletilecek.",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          GeneralButton(
                            onPressed: () {
                              if (telephoneController.text.isNotEmpty ||
                                  !isvalidPhoneNumber(
                                      telephoneController.text)) {
                                phone = telephoneController.text;
                                final snackBar = SnackBar(
                                  content: Text(
                                      '$phone nolu telefon sistemle eşleşirse doğrulama kodu SMS yollanacak.'),
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
                                    builder: (context) => Verify(
                                      phone: makePhoneValidAgain(
                                          telephoneController.text),
                                    ),
                                  ),
                                );
                                //code is sent to user's phone, backend does most of the job about verification
                                sendVerificationCode(makePhoneValidAgain(
                                    telephoneController.text));
                              }

                              //const CircularProgressIndicator();
                            },
                            child: const Text(
                              "Doğrulama Gönder",
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

  void sendVerificationCode(String phone) async {
    var url = Uri.http(deployURL, 'user/sendForgetPasswordCode');
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'phone': phone,
    });

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }
}
