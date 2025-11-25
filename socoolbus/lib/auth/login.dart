import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:my_app/auth/signup.dart';
import 'package:my_app/auth/signup_admin.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/components/general_button.dart';
import 'package:my_app/components/parent_bottom_navigation.dart';
import 'package:my_app/components/driver_bottom_navigation.dart';
import 'package:my_app/models/parent.dart';
import 'package:my_app/parent/parent_home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/school_admin/components/school_admin_bottom_navigation.dart';
import '../company_admin/components/company_admin_bottom_navigation.dart';
import '../components/phone_field.dart';
import '../constants.dart';
import '../models/user.dart';
import 'forgot.dart';
import 'signup_driver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:flutter/services.dart';

var logger = Logger();

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
Widget textDown(title) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    child: Center(
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

Widget textButtonDown(title) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    child: Center(
      child: Text(
        title,
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscure3 = true;
  bool visible = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  //final _auth = FirebaseAuth.instance;

  FocusNode focusNode = FocusNode();
  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        /* appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                onPressed: () => {},
                icon: const Icon(Icons.support_agent, color: Colors.black))
          ],
        ), */
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              Container(
                color: Colors.white10,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.65,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(12),
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
                            "Hoş Geldiniz",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 40,
                            ),
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
                            controller: passwordController,
                            obscureText: _isObscure3,
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
                              hintText: 'Şifre',
                              enabled: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 8.0, top: 15.0),
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
                                return "Şifre kısmı boş bırakılamaz!";
                              }
                              if (!regex.hasMatch(value)) {
                                return ("Lütfen en az altı karakterden oluşan geçerli bir şifre giriniz");
                              } else {
                                return null;
                              }
                            },
                            onSaved: (value) {
                              passwordController.text = value!;
                            },
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Forgot(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Yeni şifre iste",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: GeneralButton(
                              onPressed: () {
                                setState(() {
                                  visible = true;
                                });
                                signIn(phoneController.text,
                                    passwordController.text);
                              },
                              child: const Text(
                                "Giriş Yap",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                //color: Colors.white10,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      textDown("Sürücü Hesabınız yok mu?"),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpDriver(),
                              ),
                            );
                          },
                          child: textButtonDown(
                              "Ücretsiz sürücü hesabı oluşturun")),
                      textDown("Kurumsal/idari kullanıcı hesabınız yok mu?"),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpAdmin(),
                              ),
                            );
                          },
                          child: textButtonDown(
                              "Kurumsal/idari hesap talebi oluşturun"),
                        ),
                      ),
                      textDown(
                          'Veli ve öğrenci hesabı şoför tarafından oluşturulur ve kullanımı ücretsizdir.'),
                      const SizedBox(
                        height: 25,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> route(User user) async {
    if (user.role == "ADMIN") {
      //ADD
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ParentNavigation(),
        ),
      );
    } else if (user.role == "DRIVER") {
      //ADD
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DriverNavigation(),
        ),
      );
    } else if (user.role == "PARENT") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ParentNavigation(),
        ),
      );
    } else if (user.role == "SCHOOL_ADMINISTRATOR") {
      if (await isSchoolAdminApproved(user.phone)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SchoolAdminNavigation(),
          ),
        );
      } else {
        final snackBar = SnackBar(
          content: const Text('İdari hesap için onay bekleniyor.'),
          action: SnackBarAction(
            label: '',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else if (user.role == "COMPANY_ADMIN") {
      if (await isCompanyAdminApproved(user.phone)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CompanyAdminNavigation(),
          ),
        );
      } else {
        final snackBar = SnackBar(
          content: const Text('Kurumsal hesap için onay bekleniyor.'),
          action: SnackBarAction(
            label: '',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Future<bool> isSchoolAdminApproved(String phone) async {
    try {
      var phoney = makePhoneValidAgain(phone);
      var url = Uri.http(deployURL, 'user/isSchoolAdminApproved');
      logger.i(url);
      final response = await http.post(url, headers: {
        "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
      }, body: {
        'phone': phoney,
      });

      // Check the response status code
      if (response.statusCode == 200) {
        // Parse the response JSON
        final responseData = json.decode(response.body);

        // Extract the 'isApproved' value from the response
        final isApproved = responseData['isApproved'] as bool;

        // Return the 'isApproved' value
        return isApproved;
      } else {
        // If the response status code is not 200, throw an error
        throw Exception('Failed to get approval status');
      }
    } catch (error) {
      // Handle any exceptions or errors
      print('Error: $error');
      return false; // Or handle the error in a way suitable for your application
    }
  }

  Future<bool> isCompanyAdminApproved(String phone) async {
    try {
      var phoney = makePhoneValidAgain(phone);
      var url = Uri.http(deployURL, 'user/isCompanyAdminApproved');
      logger.i(url);
      final response = await http.post(url, headers: {
        "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
      }, body: {
        'phone': phoney,
      });

      // Check the response status code
      if (response.statusCode == 200) {
        // Parse the response JSON
        final responseData = json.decode(response.body);

        // Extract the 'isApproved' value from the response
        final isApproved = responseData['isApproved'] as bool;

        // Return the 'isApproved' value
        return isApproved;
      } else {
        // If the response status code is not 200, throw an error
        throw Exception('Failed to get approval status');
      }
    } catch (error) {
      // Handle any exceptions or errors
      print('Error: $error');
      return false; // Or handle the error in a way suitable for your application
    }
  }

  void signIn(String phone, String password) async {
    var phoney = makePhoneValidAgain(phone);
    var url = Uri.http(deployURL, 'login');
    logger.i(url);
    final response = await http.post(url, headers: {
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'phone': phoney,
      'password': password,
    });
    print(response.body);
    if (response.statusCode == 400) {
      final snackBar = SnackBar(
        content: const Text('Kullanıcı adı veya şifre yanlış'),
        action: SnackBarAction(
          label: '',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (response.statusCode == 200) {
      User currUser = User.fromJson(jsonDecode(response.body));
      final session = await SharedPreferences.getInstance();

      await session.setString('name', currUser.name);
      await session.setString('phone', currUser.phone);
      var json = jsonDecode(response.body);
      await session.setString('token', json['token']);
      print(await getUserToken());
      print(json['token']);
      logger.i(currUser.canHaveRoles);
      await session.setStringList('canHaveRoles', currUser.canHaveRoles);

      if (currUser.role == "PARENT") {
        url = Uri.http(deployURL, 'user/getParent');
        final responseParent = await http.post(url, headers: {
          "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
        }, body: {
          'phone': phoney,
        });
        if (responseParent.statusCode == 200) {
          Parent currParent = Parent.fromJson(jsonDecode(responseParent.body));
          await session.setString('address', currParent.address);
        }
      }
      route(currUser);
    } else {
      throw Exception('Failed to load user');
    }
    logger.i(response.body);
  }
}
