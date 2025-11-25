import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
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

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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
                            )
                          ])),
                ),
              ),
              Container(
                color: Colors.white10,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Sürücü Hesabınız yok mu?",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpDriver(),
                            ),
                          );
                        },
                        child: const Text(
                          "Ücretsiz sürücü hesabı oluşturun",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const Text(
                        "Kurumsal/idari kullanıcı hesabınız yok mu?",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpAdmin(),
                            ),
                          );
                        },
                        child: const Text(
                          "Kurumsal/idari hesap talebi oluşturun",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: const Text(
                          "Veli ve öğrenci hesabı şoför tarafından oluşturulur ve kullanımı ücretsizdir",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const Text(
                        "",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
