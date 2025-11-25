import 'package:flutter/material.dart';
import 'package:my_app/components/general_button.dart';

class PersonalInfoSettings extends StatefulWidget {
  const PersonalInfoSettings({super.key});

  @override
  State<PersonalInfoSettings> createState() => _ParentSettingsPersonalState();
}

class _ParentSettingsPersonalState extends State<PersonalInfoSettings> {
  bool _isObscure3 = true;
  bool visible = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kişisel Bilgiler")),
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.white10,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.80,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(12),
                child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("", style: TextStyle(fontSize: 18)),
                      const Text("Mehmet Karaoğlu",
                          style: TextStyle(fontSize: 26)),
                      const Text("555-555-5555",
                          style: TextStyle(fontSize: 18)),
                      const Text("", style: TextStyle(fontSize: 18)),
                      const Text("Birinci Telefon",
                          style: TextStyle(fontSize: 18)),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: telephoneController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "555-555-5555",
                          enabled: true,
                          contentPadding: const EdgeInsets.only(
                              left: 14.0, bottom: 8.0, top: 8.0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Telefon kısmı boş bırakılamaz!";
                          }
                          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                              .hasMatch(value)) {
                            return ("Lütfen geçerli bir telefon numarası girin");
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          telephoneController.text = value!;
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text("İkinci Telefon",
                          style: TextStyle(fontSize: 18)),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: telephoneController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          enabled: true,
                          contentPadding: const EdgeInsets.only(
                              left: 14.0, bottom: 8.0, top: 8.0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Telefon kısmı boş bırakılamaz!";
                          }
                          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                              .hasMatch(value)) {
                            return ("Lütfen geçerli bir telefon numarası girin");
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          telephoneController.text = value!;
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text("E-mail", style: TextStyle(fontSize: 18)),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: telephoneController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          enabled: true,
                          contentPadding: const EdgeInsets.only(
                              left: 14.0, bottom: 8.0, top: 8.0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Telefon kısmı boş bırakılamaz!";
                          }
                          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                              .hasMatch(value)) {
                            return ("Lütfen geçerli bir telefon numarası girin");
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          telephoneController.text = value!;
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GeneralButton(
                          onPressed: () {
                            print("Save Parent Address Info");
                          },
                          child: const Text(
                            "Kaydet",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Visibility(
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          visible: visible,
                          child: Container(
                              child: const CircularProgressIndicator(
                            color: Colors.white,
                          ))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
