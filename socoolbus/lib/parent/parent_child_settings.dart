import 'package:flutter/material.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/components/general_button.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/models/student.dart';
import 'package:my_app/components/select_child.dart';

class ChildInfoSettings extends StatefulWidget {
  const ChildInfoSettings({super.key});

  @override
  State<ChildInfoSettings> createState() => _ParentSettingsChildState();
}

class _ParentSettingsChildState extends State<ChildInfoSettings> {
  bool _isObscure3 = true;
  bool visible = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController telephoneController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  Student? selectedStudent;
  late Future<List<Student>> stuList;


@override
  void initState() {
    stuList = getParentChildren(getUserPhone());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Çocuk Bilgileri"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.white10,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.70,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(6),
                child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("", style: TextStyle(fontSize: 18)),
                      FutureBuilder<List<Student>>(
                        future: stuList,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text('Bir hata oluştu!'),
                            );
                          } else if (!snapshot.hasData) {
                            return const Center(
                                child: SizedBox(
                                    height: 40,
                                    child: LinearProgressIndicator(
                                      color: COLOR_GREY,
                                    )) //Text('Eklenen okulunuz yok!'),
                                );
                          } else if (snapshot.hasData) {
                            return DropdownButtonChild(
                              list: snapshot.data!,
                              width: MediaQuery.of(context).size.width * 0.8,
                              onChanged: (p0) {
                                setState(() {
                                  selectedStudent = p0;
                                });
                              },
                              selectedValue: selectedStudent,
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const Text("Aziz Karaoğlu",
                          style: TextStyle(fontSize: 26)),
                      const Text("", style: TextStyle(fontSize: 18)),
                      const Text("Mehmetçik İlkokulu",
                          style: TextStyle(fontSize: 22)),
                      const Text("", style: TextStyle(fontSize: 14)),
                      const Text("1. Sınıf", style: TextStyle(fontSize: 18)),
                      const SizedBox(
                        height: 30,
                      ),
                      const Text("Telefon", style: TextStyle(fontSize: 18)),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: telephoneController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "",
                          enabled: true,
                          contentPadding: const EdgeInsets.only(
                              left: 14.0, bottom: 8.0, top: 8.0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white),
                            borderRadius: new BorderRadius.circular(10),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white),
                            borderRadius: new BorderRadius.circular(10),
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
