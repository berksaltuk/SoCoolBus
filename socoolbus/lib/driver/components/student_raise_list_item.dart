import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_app/driver/components/finance_button.dart';
import 'package:my_app/my_enum.dart';
import 'package:http/http.dart' as http;
import '../../components/common_methods.dart';
import '../../constants.dart';

class StudentRaiseList extends StatefulWidget {
  final String studentId;
  final String name;
  final int index;
  final VoidCallback updateParent;
  StudentRaiseList(
      {required this.studentId,
      required this.name,
      required this.index,
      required this.updateParent,
      super.key});

  @override
  _StudentRaiseListState createState() => _StudentRaiseListState();
}

class _StudentRaiseListState extends State<StudentRaiseList> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                Text(
                  (widget.index + 1).toString(), // To show indexes start from 1
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                    width: 40,
                    child: IconButton(
                      icon: const Icon(Icons.trending_up),
                      onPressed: () {
                        openRaiseDialog();
                      },
                    )),
                SizedBox(
                    width: 40,
                    child: IconButton(
                      icon: const Icon(Icons.plus_one),
                      onPressed: () {
                        openAdditionalPaymentDialog();
                      },
                    )),
              ],
            )
          ],
        ),
      ]),
    );
  }

  openRaiseDialog() {
    final TextEditingController raiseController =
        TextEditingController(text: "0");
    PaymentPreference paymentPreference = PaymentPreference.montly;
    PaymentWho paymentwho = PaymentWho.parent;

    int currentCharge = 0;

    String startMonth;
    String endMonth;
    String remainingInstallment;

    getStudentPaymentInfo(widget.studentId).then((json) {
      startMonth = json["start"] ?? "";
      endMonth = json["end"] ?? "";
      remainingInstallment = "${json["monthsRemaining"]} Ay";
      currentCharge = json["charge"] ?? 0;

      paymentPreference = paymentPreference.fromInt(json["paymentPreference"]);
      paymentwho = paymentwho.fromInt(json["whogondothePayment"]);

      showDialog(
          context: context,
          builder: (context) {
            Size size = MediaQuery.of(context).size;
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                  title: const Text("Zam Yap"),
                  content: SingleChildScrollView(
                      child: Column(
                    children: [
                      Container(
                        width: size.width,
                        margin: const EdgeInsets.only(bottom: 10),
                        height: size.height * 0.25,
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10)),
                        child: ListView(
                          children: [
                            Row(children: [
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: const Text("Ödemeyi Yapan")),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.07),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  child: const Text("Ödeme Şekli")),
                            ]),
                            SizedBox(height: size.height * 0.015),
                            Row(children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child:
                                    Center(child: Text(paymentwho.getString())),
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.07),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.25,
                                child: Center(
                                    child: Text(paymentPreference.getString())),
                              ),
                            ]),
                            const Text(
                                "-----------------------------------------------------------",
                                softWrap: false),
                            Row(children: [
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  child: const Text("Kalan Süre")),
                              SizedBox(
                                width: size.width * 0.1,
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.30,
                                  child: const Text("Zaman Dilimi")),
                            ]),
                            SizedBox(height: size.height * 0.008),
                            Row(children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.25,
                                child: Text(remainingInstallment),
                              ),
                              SizedBox(width: size.width * 0.1),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.30,
                                child: Text("$startMonth - $endMonth"),
                              ),
                            ]),
                            const Text(
                                "-----------------------------------------------------------",
                                softWrap: false),
                            Row(
                              children: [
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.11,
                                    child: const Text("Eski Aylık:")),
                                Text(currentCharge.toString()),
                                const Text("₺"),
                                SizedBox(width: size.width * 0.1),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.135,
                                    child: const Text("Zam Miktarı:")),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.02,
                                ),
                                Flexible(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: SizedBox(
                                      height: 40,
                                      width: size.width * 0.26,
                                      child: TextField(
                                        scrollPadding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom +
                                                40), //40 is 4 times font number
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(
                                              4) //aylık ücret maks 4 basamak olabilir
                                        ],
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: COLOR_LIGHT_GREY),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: COLOR_DARK_GREY),
                                          ),
                                          //hintText: '',
                                        ),
                                        controller: raiseController,
                                        onSubmitted: (value) {
                                          raiseController.text = value;
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            raiseController.text = value;
                                            raiseController.selection =
                                                TextSelection.collapsed(
                                                    offset: raiseController
                                                        .text.length);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const Text("₺"),
                              ],
                            )
                          ],
                        ),
                      ),
                      FinanceButton(
                        //navigate to payment list page
                        onPressed: () async {
                          setState(() {});
                          if (raiseController.text == "0" ||
                              raiseController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lütfen ücret giriniz!'),
                              ),
                            );
                          } else {
                            if (await makeRaise(
                                widget.studentId, raiseController.text)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Başarılı bir şekilde zam yapıldı!'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Zam yapılamadı, daha sonra lütfen tekrar deneyiniz!'),
                                ),
                              );
                            }
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          'Güncelle',
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ),
                    ],
                  )));
            });
          });
    });
  }

  openAdditionalPaymentDialog() {
    final TextEditingController amountController =
        TextEditingController(text: "0");
    TextEditingController dueDate = TextEditingController();
    DateTime now = DateTime.now();
    PaymentPreference paymentPreference = PaymentPreference.montly;
    PaymentWho paymentwho = PaymentWho.parent;
    String? duration;
    int totalFee = 0;
    showDialog(
        context: context,
        builder: (context) {
          Size size = MediaQuery.of(context).size;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                title: const Text("Ekstra Ödeme Ekle"),
                content: SingleChildScrollView(
                    child: Column(
                  children: [
                    Container(
                      width: size.width,
                      margin: const EdgeInsets.only(bottom: 10),
                      height: size.height * 0.17,
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10)),
                      child: ListView(
                        children: [
                          Flexible(
                              child: SizedBox(
                            height: 50,
                            child: TextField(
                              controller: dueDate,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(
                                  Icons.event_note,
                                  color: COLOR_DARK_GREY,
                                ),
                                labelText: 'Tarih',
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: COLOR_LIGHT_GREY),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: COLOR_DARK_GREY),
                                ),
                                labelStyle: TextStyle(color: COLOR_DARK_GREY),
                              ),
                              readOnly: true, //user wont able to edit text
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: now.add(const Duration(days: 7)),
                                  lastDate: now.add(const Duration(days: 120)),
                                  firstDate: now.add(const Duration(days: 3)),
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        colorScheme: const ColorScheme.light(
                                            primary: COLOR_DARK_GREY),
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor: COLOR_DARK_GREY,
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (pickedDate != null) {
                                  print(
                                      pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                  String formattedDate =
                                      DateFormat('yyyy-MM-dd')
                                          .format(pickedDate);
                                  print(formattedDate);

                                  setState(() {
                                    dueDate.text =
                                        formattedDate; //set output date to TextField value.
                                  });
                                } else {
                                  print("Date is not selected");
                                }
                              },
                            ),
                          )),
                          SizedBox(height: size.height * 0.025),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  child: const Text("Miktar:")),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.02,
                              ),
                              Flexible(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: SizedBox(
                                    height: 40,
                                    width: size.width * 0.26,
                                    child: TextField(
                                      scrollPadding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom +
                                              40), //40 is 4 times font number
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(
                                            4) //aylık ücret maks 4 basamak olabilir
                                      ],
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 10),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: COLOR_LIGHT_GREY),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: COLOR_DARK_GREY),
                                        ),
                                        //hintText: '',
                                      ),
                                      controller: amountController,
                                      onSubmitted: (value) {
                                        amountController.text = value;
                                      },
                                      onChanged: (value) {
                                        setState(() {
                                          amountController.text = value;
                                          amountController.selection =
                                              TextSelection.collapsed(
                                                  offset: amountController
                                                      .text.length);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const Text("₺"),
                            ],
                          )
                        ],
                      ),
                    ),
                    FinanceButton(
                      //navigate to payment list page
                      onPressed: () async {
                        setState(() {});
                        if (amountController.text == "0") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lütfen ücret giriniz!'),
                            ),
                          );
                        } else {
                          Navigator.pop(context);
                          if (await addAdditionalPaymnt(widget.studentId,
                              amountController.text, dueDate.text)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ekstra ücret eklendi!'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Ücret eklenemedi. Bir hatayla karşılaşıldı!'),
                              ),
                            );
                          }
                        }
                        //TO DO: need to check school start time is not 2(full day)
                        //in other words no radio button is selected while two devre okul is selected
                      },
                      child: Text(
                        'Ekle',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ),
                  ],
                )));
          });
        });
  }
}

Future<Map<String, dynamic>> getStudentPaymentInfo(String studentId) async {
  var url = Uri.http(deployURL, 'driver/getMakeRaiseInfo');
  print(url);

  final response = await http.post(url, headers: {
    HttpHeaders.authorizationHeader: await getUserToken(),
    "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
  }, body: {
    'phone': await getUserPhone(),
    'studentID': studentId,
  });
  print(response.body);

  return jsonDecode(response.body);
}

Future<bool> makeRaise(String studentID, String raiseAmount) async {
  var url = Uri.http(deployURL, 'driver/makeRaise');

  final response = await http.post(url, headers: {
    HttpHeaders.authorizationHeader: await getUserToken(),
    "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
  }, body: {
    'driverPhone': await getUserPhone(),
    'studentID': studentID,
    'raiseAmount': raiseAmount,
  });
  print(response.body);
  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

Future<bool> addAdditionalPaymnt(
    String studentID, String amount, String dueDate) async {
  var url = Uri.http(deployURL, 'driver/addAdditionalPayment');

  final response = await http.post(url, headers: {
    HttpHeaders.authorizationHeader: await getUserToken(),
    "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
  }, body: {
    'driverPhone': await getUserPhone(),
    'studentID': studentID,
    'dueDate': dueDate,
    'amount': amount,
  });
  print(response.body);
  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}
