import 'dart:convert';
import 'dart:io';
import 'package:date_field/date_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/components/select_general.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/driver/components/driver_profile_document_item.dart';
import 'package:my_app/driver/components/finance_button.dart';
import 'package:my_app/models/document.dart';
import 'package:my_app/my_enum.dart';

class ProfileDocumentsPage extends StatefulWidget {
  const ProfileDocumentsPage({super.key});

  @override
  State<ProfileDocumentsPage> createState() => _ProfileDocumentsPageState();
}

class _ProfileDocumentsPageState extends State<ProfileDocumentsPage> {
  File? file;
  String? selectedDocumentType;
  TextEditingController noteController = TextEditingController();
  DateTime? docDate;

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      file = File(pickedFile!.path);
    });
  }

  Future<void> _uploadPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      file = File(pickedFile!.path);
    });
  }

  Future<void> _uploadPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;
    final pickedFile = File(result.files.single.path!);

    setState(() {
      file = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Evraklarım"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          child: ListView(
            children: [
              //select school
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    "Yüklenen Evraklar",
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  width: size.width,
                  margin: const EdgeInsets.only(bottom: 10),
                  height: size.height * 0.3,
                  child: FutureBuilder<List<Document>>(
                    future: getDriverDocument(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                              'Bir hata oluştu!\n${snapshot.error!.toString()}'),
                        );
                      } else if (snapshot.hasData) {
                        if (snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('Yüklenen evrak bulunamadı!'),
                          );
                        }
                        return ListView(
                          children: [
                            for (var document in snapshot.data!)
                              DriverProfileDocumentItem(
                                documentId: document.documentId,
                                title: document.type.getEnum(),
                                validUntil: document.date,
                                uploadDate: DateTime.now().toUtc(),
                                note: document.description,
                                validStatus: document.status,
                              ),
                          ],
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    "Belge Ekle",
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ),
              ),
              SizedBox(
                  width: size.width,
                  //margin: EdgeInsets.only(bottom: 10),

                  height: size.height * 0.36,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // ignore: prefer_const_literals_to_create_immutables
                    children: <Widget>[
                      DropdownGeneral(
                        searchable: false,
                        list: const ["Ruhsat", "Ehliyet", "Psikoteknik"],
                        onChanged: (value) {
                          setState(() {
                            selectedDocumentType = value;
                          });
                        },
                        selectedValue: selectedDocumentType,
                      ),
                      /*const Flexible(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: SizedBox(
                            height: 30,
                            width: double.infinity,
                            child: TextField(
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 10),
                                border: OutlineInputBorder(),
                                hintText: 'Belge Tipi',
                              ),
                            ),
                          ),
                        ),
                      ),*/
                      SizedBox(
                        height: 55,
                        child: Flexible(
                          child: DateTimeFormField(
                            decoration: const InputDecoration(
                              hintStyle: TextStyle(color: Colors.black45),
                              errorStyle: TextStyle(color: Colors.redAccent),
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.event_note),
                              labelText: 'Tarih',
                            ),
                            dateFormat: DateFormat('d MMM y', 'tr'),
                            lastDate: DateTime.now().add(const Duration(
                                days: 1900)), // Slightly more than 5 years
                            firstDate:
                                DateTime.now().add(const Duration(days: 6)),
                            mode: DateTimeFieldPickerMode.date,
                            autovalidateMode: AutovalidateMode.always,
                            validator: (e) => (e?.day ?? 0) == 1
                                ? 'Please not the first day'
                                : null, // Buna gerek yok muhtemelen
                            onDateSelected: (DateTime value) {
                              docDate = value;
                              print(value);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextField(
                            controller: noteController,
                            keyboardType: TextInputType.multiline,
                            autocorrect: false,
                            maxLines: 2,
                            maxLength: 140,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10),
                              border: OutlineInputBorder(),
                              hintText: 'Not',
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: ElevatedButton(
                              onPressed: _takePhoto,
                              child: const Text('Fotoğraf Çek'),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            flex: 4,
                            child: ElevatedButton(
                              onPressed: _uploadPhoto,
                              child: const Text('Fotoğraf Yükle'),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            flex: 3,
                            child: ElevatedButton(
                              onPressed: _uploadPDF,
                              child: const Text('PDF Yükle'),
                            ),
                          ),
                        ],
                      ),
                      file != null
                          ? const Text("Dosya seçildi!")
                          : const SizedBox(),
                      FinanceButton(
                          onPressed: () {
                            uploadFile(file, selectedDocumentType, docDate,
                                noteController.text);
                          },
                          child: const Text("Belge Ekle"))
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  void uploadFile(
      File? file, String? docType, DateTime? docDate, String docNotes) async {
    if (docType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lüften döküman tipini seçiniz!'),
        ),
      );
      return;
    } else if (docDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen döküman geçerlilik tarihi seçiniz!'),
        ),
      );
      return;
    } else if (file == null) {
      print(docDate);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lüften dökümanı seçip yükleyiniz!'),
        ),
      );
      return;
    }

    if (docType == "Ehliyet") {
      docType = "LICENSE";
    } else if (docType == "Ruhsat") {
      docType = "REGISTRATION";
    } else if (docType == "Psikoteknik") {
      docType = "PSYCHOTECHNIC";
    }
    var url = Uri.http(deployURL, 'driver/uploadFile');
    print(url);
    var request = http.MultipartRequest('POST', url)
      ..headers[HttpHeaders.authorizationHeader] = await getUserToken()
      ..fields['driverPhone'] = await getUserPhone()
      ..fields['documentType'] = docType
      ..fields['documentDate'] = docDate.toUtc().toString()
      ..fields['documentNote'] = docNotes
      ..files.add(await http.MultipartFile.fromPath('file', file.path));
    final response = await request.send();
    if (response.statusCode == 200) {
      final snackBar = SnackBar(
        content: const Text('Evrak eklendi.'),
        action: SnackBarAction(
          label: '',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileDocumentsPage(),
        ),
      );
    }
    ;
  }

  Future<List<Document>> getDriverDocument() async {
    var url = Uri.http(deployURL, 'driver/getFiles');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'driverPhone': await getUserPhone()
    });
    print(response.body);

    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<Document>((json) => Document.fromJson(json)).toList();
  }
}
