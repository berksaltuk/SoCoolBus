import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/driver/components/finance_button.dart';
import 'package:http/http.dart' as http;

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final TextEditingController plateCont = TextEditingController();
  final TextEditingController modelCont = TextEditingController();
  final TextEditingController seatCont = TextEditingController();
  final TextEditingController fromDateInputM = TextEditingController();
  final TextEditingController toDateInputM = TextEditingController();
  final TextEditingController fromDateInputS = TextEditingController();
  final TextEditingController toDateInputS = TextEditingController();
  final TextEditingController muayeneCont = TextEditingController();
  String muayeneStart = "";
  final TextEditingController sigortaCont = TextEditingController();
  String sigortaStart = "";

  bool _isLoaded = false;

  @override
  initState() {
    getSchoolBus().then((value) {
      plateCont.text = value['plate'] ?? "Plaka yok";
      modelCont.text = value['busModel'] ?? "Model yok";
      seatCont.text = value['seatCount'].toString();
      if (value['muayeneEnds'] != null) {
        muayeneCont.text = DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(value['muayeneEnds']));
      } else {
        muayeneCont.text = "Muayene Tarihi Yok";
      }

      if (value['sigortaEnds'] != null) {
        sigortaCont.text = DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(value['sigortaEnds']));
      } else {
        sigortaCont.text = "Sigorta Tarihi Yok";
      }
      setState(() {
        _isLoaded = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return _isLoaded
        ? WillPopScope(
            onWillPop: () async => true,
            child: Scaffold(
                appBar: AppBar(
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Araç Bilgilerini Düzenle',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView(children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "\t\tAraç Bilgileri",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: plateCont,
                      readOnly: true,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Araç Plakası",
                        labelStyle: const TextStyle(color: Colors.black),
                        enabled: true,
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 0.0, top: 8.0),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: modelCont,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Araç Modeli",
                        labelStyle: const TextStyle(color: Colors.black),
                        enabled: true,
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 0.0, top: 8.0),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: seatCont,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Yolcu Kapasitesi",
                        labelStyle: const TextStyle(color: Colors.black),
                        enabled: true,
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 0.0, top: 8.0),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: muayeneCont,
                      //editing controller of this TextField
                      decoration: const InputDecoration(
                          labelStyle: TextStyle(color: COLOR_DARK_GREY),
                          iconColor: COLOR_BLACK,
                          icon: Icon(Icons.calendar_today), //icon of text field
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: COLOR_DARK_GREY),
                          ),
                          //icon of text field
                          labelText:
                              "Muayene Geçerlilik Tarihi" //label text of field
                          ),
                      readOnly: false,
                      //set it true, so that user will not able to edit text
                      onTap: () async {
                        //DateTime? pickedDate;
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          confirmText: "Seç",
                          cancelText: "İptal",
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          //DateTime.now() - not to allow to choose before today.
                          lastDate:
                              DateTime.now().add(const Duration(days: 730)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Colors.orangeAccent, // <-- SEE HERE
                                  onPrimary: Colors.black, // <-- SEE HERE
                                  onSurface: Colors.black, // <-- SEE HERE
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    primary: Colors.orange, // button text color
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                          //currentDate: pickedDate
                        );

                        if (pickedDate != null) {
                          print(
                              pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                          DateTime ms =
                              pickedDate.subtract(const Duration(days: 730));
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                          print(
                              formattedDate); //formatted date output using intl package =>  2021-03-16
                          setState(() {
                            muayeneStart = DateFormat('yyyy-MM-dd').format(ms);
                            muayeneCont.text =
                                formattedDate; //set output date to TextField value.
                          });
                        } else {
                          print("some error meh");
                          muayeneCont.text = "tarih seçilemedi...";
                        }
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: sigortaCont,
                      //editing controller of this TextField
                      decoration: const InputDecoration(
                          labelStyle: TextStyle(color: COLOR_DARK_GREY),
                          iconColor: COLOR_BLACK,
                          icon: Icon(Icons.calendar_today), //icon of text field
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: COLOR_DARK_GREY),
                          ),
                          //icon of text field
                          labelText:
                              "Sigorta Geçerlilik Tarihi" //label text of field
                          ),
                      readOnly: false,
                      //set it true, so that user will not able to edit text
                      onTap: () async {
                        //DateTime? pickedDate;
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          confirmText: "Seç",
                          cancelText: "İptal",
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          //DateTime.now() - not to allow to choose before today.
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Colors.orangeAccent, // <-- SEE HERE
                                  onPrimary: Colors.black, // <-- SEE HERE
                                  onSurface: Colors.black, // <-- SEE HERE
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    primary: Colors.orange, // button text color
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                          //currentDate: pickedDate
                        );

                        if (pickedDate != null) {
                          print(
                              pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                          DateTime ss =
                              pickedDate.subtract(const Duration(days: 365));
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                          print(
                              formattedDate); //formatted date output using intl package =>  2021-03-16
                          setState(() {
                            sigortaStart = DateFormat('yyyy-MM-dd').format(ss);
                            sigortaCont.text =
                                formattedDate; //set output date to TextField value.
                          });
                        } else {
                          print("some error meh");
                          sigortaCont.text = "tarih seçilemedi...";
                        }
                      },
                    ),
                    /* Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: size.width * 0.45,
                          child: FinanceButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: ((context) => AlertDialog(
                                          title: const Text(
                                              "Muayene Tarih Aralığı"),
                                          actions: [
                                            TextButton(
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          COLOR_ORANGE)),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Kaydet"),
                                            )
                                          ],
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(15),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    5,
                                                child: Center(
                                                    child: TextField(
                                                  controller: fromDateInputM,
                                                  //editing controller of this TextField
                                                  decoration:
                                                      const InputDecoration(
                                                          labelStyle: TextStyle(
                                                              color:
                                                                  COLOR_DARK_GREY),
                                                          iconColor:
                                                              COLOR_BLACK,
                                                          icon: Icon(Icons
                                                              .calendar_today), //icon of text field
                                                          focusedBorder:
                                                              UnderlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color:
                                                                    COLOR_DARK_GREY),
                                                          ),
                                                          //icon of text field
                                                          labelText:
                                                              "Başlangıç Tarihi" //label text of field
                                                          ),
                                                  readOnly: false,
                                                  //set it true, so that user will not able to edit text
                                                  onTap: () async {
                                                    //DateTime? pickedDate;
                                                    final DateTime? pickedDate =
                                                        await showDatePicker(
                                                      context: context,
                                                      confirmText: "Seç",
                                                      cancelText: "İptal",
                                                      initialDate:
                                                          DateTime.now(),

                                                      firstDate: DateTime.now()
                                                          .subtract(
                                                              const Duration(
                                                                  days: 729)),
                                                      //DateTime.now() - not to allow to choose before today.
                                                      lastDate: DateTime.now(),
                                                      builder:
                                                          (context, child) {
                                                        return Theme(
                                                          data:
                                                              Theme.of(context)
                                                                  .copyWith(
                                                            colorScheme:
                                                                const ColorScheme
                                                                    .light(
                                                              primary: Colors
                                                                  .orangeAccent, // <-- SEE HERE
                                                              onPrimary: Colors
                                                                  .black, // <-- SEE HERE
                                                              onSurface: Colors
                                                                  .black, // <-- SEE HERE
                                                            ),
                                                            textButtonTheme:
                                                                TextButtonThemeData(
                                                              style: TextButton
                                                                  .styleFrom(
                                                                primary: Colors
                                                                    .orange, // button text color
                                                              ),
                                                            ),
                                                          ),
                                                          child: child!,
                                                        );
                                                      },
                                                      //currentDate: pickedDate
                                                    );

                                                    if (pickedDate != null) {
                                                      print(
                                                          pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                                      String formattedDate =
                                                          DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(
                                                                  pickedDate);
                                                      print(
                                                          formattedDate); //formatted date output using intl package =>  2021-03-16
                                                      setState(() {
                                                        fromDateInputM.text =
                                                            formattedDate; //set output date to TextField value.
                                                      });
                                                    } else {
                                                      print("some error meh");
                                                      fromDateInputM.text =
                                                          "tarih seçilemedi...";
                                                    }
                                                  },
                                                )),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(15),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    5,
                                                child: Center(
                                                    child: TextField(
                                                  controller: toDateInputM,
                                                  //editing controller of this TextField
                                                  decoration:
                                                      const InputDecoration(
                                                          labelStyle: TextStyle(
                                                              color:
                                                                  COLOR_DARK_GREY),
                                                          iconColor:
                                                              COLOR_BLACK,
                                                          icon: Icon(Icons
                                                              .calendar_today), //icon of text field
                                                          focusedBorder:
                                                              UnderlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color:
                                                                    COLOR_DARK_GREY),
                                                          ),
                                                          labelText:
                                                              "Bitiş Tarihi" //label text of field
                                                          ),
                                                  readOnly: false,
                                                  //set it true, so that user will not able to edit text
                                                  onTap: () async {
                                                    //DateTime? pickedDate;
                                                    final DateTime? pickedDate =
                                                        await showDatePicker(
                                                      context: context,
                                                      confirmText: "Seç",
                                                      cancelText: "İptal",
                                                      initialDate:
                                                          DateTime.now(),
                                                      firstDate: DateTime.now(),
                                                      //DateTime.now() - not to allow to choose before today.
                                                      lastDate: DateTime.now()
                                                          .add(const Duration(
                                                              days: 730)),
                                                      builder:
                                                          (context, child) {
                                                        return Theme(
                                                          data:
                                                              Theme.of(context)
                                                                  .copyWith(
                                                            colorScheme:
                                                                const ColorScheme
                                                                    .light(
                                                              primary: Colors
                                                                  .orangeAccent, // <-- SEE HERE
                                                              onPrimary: Colors
                                                                  .black, // <-- SEE HERE
                                                              onSurface: Colors
                                                                  .black, // <-- SEE HERE
                                                            ),
                                                            textButtonTheme:
                                                                TextButtonThemeData(
                                                              style: TextButton
                                                                  .styleFrom(
                                                                primary: Colors
                                                                    .orange, // button text color
                                                              ),
                                                            ),
                                                          ),
                                                          child: child!,
                                                        );
                                                      },
                                                      //currentDate: pickedDate
                                                    );

                                                    if (pickedDate != null) {
                                                      print(
                                                          pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                                      String formattedDate =
                                                          DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(
                                                                  pickedDate);
                                                      print(
                                                          formattedDate); //formatted date output using intl package =>  2021-03-16
                                                      setState(() {
                                                        toDateInputM.text =
                                                            formattedDate; //set output date to TextField value.
                                                      });
                                                    } else {
                                                      print("some error meh");
                                                      fromDateInputM.text =
                                                          "tarih seçilemedi...";
                                                    }
                                                  },
                                                )),
                                              ),
                                            ],
                                          ),
                                        )));
                              },
                              child: const Text("Muayene Bilgisi")),
                        ),
                        SizedBox(
                          width: size.width * 0.45,
                          child: FinanceButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: ((context) => AlertDialog(
                                          title: const Text(
                                              "Sigorta Tarih Aralığı"),
                                          actions: [
                                            TextButton(
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          COLOR_ORANGE)),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Kaydet"),
                                            )
                                          ],
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(15),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    5,
                                                child: Center(
                                                    child: TextField(
                                                  controller: fromDateInputM,
                                                  //editing controller of this TextField
                                                  decoration:
                                                      const InputDecoration(
                                                          labelStyle: TextStyle(
                                                              color:
                                                                  COLOR_DARK_GREY),
                                                          iconColor:
                                                              COLOR_BLACK,
                                                          icon: Icon(Icons
                                                              .calendar_today), //icon of text field
                                                          focusedBorder:
                                                              UnderlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color:
                                                                    COLOR_DARK_GREY),
                                                          ), //icon of text field
                                                          labelText:
                                                              "Başlangıç Tarihi" //label text of field
                                                          ),
                                                  readOnly: false,
                                                  //set it true, so that user will not able to edit text
                                                  onTap: () async {
                                                    //DateTime? pickedDate;
                                                    final DateTime? pickedDate =
                                                        await showDatePicker(
                                                      context: context,
                                                      confirmText: "Seç",
                                                      cancelText: "İptal",
                                                      initialDate:
                                                          DateTime.now(),
                                                      firstDate: DateTime.now()
                                                          .subtract(
                                                              const Duration(
                                                                  days: 365)),
                                                      //DateTime.now() - not to allow to choose before today.
                                                      lastDate: DateTime.now(),
                                                      builder:
                                                          (context, child) {
                                                        return Theme(
                                                          data:
                                                              Theme.of(context)
                                                                  .copyWith(
                                                            colorScheme:
                                                                const ColorScheme
                                                                    .light(
                                                              primary: Colors
                                                                  .orangeAccent, // <-- SEE HERE
                                                              onPrimary: Colors
                                                                  .black, // <-- SEE HERE
                                                              onSurface: Colors
                                                                  .black, // <-- SEE HERE
                                                            ),
                                                            textButtonTheme:
                                                                TextButtonThemeData(
                                                              style: TextButton
                                                                  .styleFrom(
                                                                primary: Colors
                                                                    .orange, // button text color
                                                              ),
                                                            ),
                                                          ),
                                                          child: child!,
                                                        );
                                                      },
                                                      //currentDate: pickedDate
                                                    );

                                                    if (pickedDate != null) {
                                                      print(
                                                          pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                                      String formattedDate =
                                                          DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(
                                                                  pickedDate);
                                                      print(
                                                          formattedDate); //formatted date output using intl package =>  2021-03-16
                                                      setState(() {
                                                        fromDateInputS.text =
                                                            formattedDate; //set output date to TextField value.
                                                      });
                                                    } else {
                                                      print("some error meh");
                                                      fromDateInputS.text =
                                                          "tarih seçilemedi...";
                                                    }
                                                  },
                                                )),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(15),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    5,
                                                child: Center(
                                                    child: TextField(
                                                  controller: toDateInputM,
                                                  //editing controller of this TextField
                                                  decoration:
                                                      const InputDecoration(
                                                          labelStyle: TextStyle(
                                                              color:
                                                                  COLOR_DARK_GREY),
                                                          iconColor:
                                                              COLOR_BLACK,
                                                          icon: Icon(Icons
                                                              .calendar_today), //icon of text field
                                                          focusedBorder:
                                                              UnderlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color:
                                                                    COLOR_DARK_GREY),
                                                          ), //icon of text field
                                                          labelText:
                                                              "Bitiş Tarihi" //label text of field
                                                          ),
                                                  readOnly: false,
                                                  //set it true, so that user will not able to edit text
                                                  onTap: () async {
                                                    final DateTime?
                                                        pickedDateS =
                                                        await showDatePicker(
                                                      context: context,
                                                      confirmText: "Seç",
                                                      cancelText: "İptal",
                                                      initialDate:
                                                          DateTime.now(),
                                                      firstDate: DateTime.now(),
                                                      //DateTime.now() - not to allow to choose before today.
                                                      lastDate: DateTime.now()
                                                          .add(const Duration(
                                                              days: 365)),
                                                      builder:
                                                          (context, child) {
                                                        return Theme(
                                                          data:
                                                              Theme.of(context)
                                                                  .copyWith(
                                                            colorScheme:
                                                                const ColorScheme
                                                                    .light(
                                                              primary: Colors
                                                                  .orangeAccent, // <-- SEE HERE
                                                              onPrimary: Colors
                                                                  .black, // <-- SEE HERE
                                                              onSurface: Colors
                                                                  .black, // <-- SEE HERE
                                                            ),
                                                            textButtonTheme:
                                                                TextButtonThemeData(
                                                              style: TextButton
                                                                  .styleFrom(
                                                                primary: Colors
                                                                    .orange, // button text color
                                                              ),
                                                            ),
                                                          ),
                                                          child: child!,
                                                        );
                                                      },
                                                      //currentDate: pickedDate
                                                    );

                                                    if (pickedDateS != null) {
                                                      print(
                                                          pickedDateS); //pickedDate output format => 2021-03-10 00:00:00.000
                                                      String formattedDate =
                                                          DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(
                                                                  pickedDateS);
                                                      print(
                                                          formattedDate); //formatted date output using intl package =>  2021-03-16
                                                      setState(() {
                                                        toDateInputS.text =
                                                            formattedDate; //set output date to TextField value.
                                                      });
                                                    } else {
                                                      print("some error meh");
                                                      fromDateInputS.text =
                                                          "tarih seçilemedi...";
                                                    }
                                                  },
                                                )),
                                              ),
                                            ],
                                          ),
                                        )));
                              },
                              child: const Text("Sigorta Bilgisi")),
                        ),
                      ],
                    ),
                    */
                    const SizedBox(
                      height: 20,
                    ),
                    FinanceButton(
                      onPressed: () {
                        String muayeneContS = muayeneCont.text;
                        setSchoolBus(
                          modelCont.text,
                          seatCont.text,
                          muayeneStart,
                          muayeneCont.text,
                          sigortaStart,
                          sigortaCont.text,
                        );
/*                         setSchoolBus(
                          modelCont.text,
                          seatCont.text,
                          fromDateInputM.text,
                          toDateInputM.text,
                          fromDateInputS.text,
                          toDateInputS.text,
                        ); */
                      },
                      child: Text(
                        'Kaydet',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ),
                  ]),
                )))
        : const Center(
            child: CircularProgressIndicator(
            color: Colors.black,
          ));
  }

  Future<dynamic> setSchoolBus(String model, String seat, String fromDateM,
      String toDateM, String fromDateS, String toDateS) async {
    var url = Uri.http(deployURL, 'driver/updateSchoolBus');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'phone': await getUserPhone(),
      "busModel": model,
      "seatCount": seat,
      "muayeneStarts": fromDateM,
      "muayeneEnds": toDateM,
      "sigortaStarts": fromDateS,
      "sigortaEnds": toDateS,
    });
    print(response.body);
    if (response.body ==
        "{\"msg\":\"School bus setting is updated successfully.\"}") {
      final snackBar = SnackBar(
        content: const Text('Araç başarıyla güncellendi!'),
        action: SnackBarAction(
          label: '',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar); // Show the SnackBar
      Navigator.of(context).pop();
    }

    final parsed = jsonDecode(response.body);
    return parsed;
  }

  Future<dynamic> getSchoolBus() async {
    var url = Uri.http(deployURL, 'driver/getSchoolBusByDriver');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'phone': await getUserPhone()
    });
    print(response.body);

    final parsed = jsonDecode(response.body);
    return parsed;
  }
}
