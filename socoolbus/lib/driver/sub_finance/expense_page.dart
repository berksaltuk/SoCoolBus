import 'dart:convert';
import 'dart:io';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:intl/intl.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/components/select_general.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/driver/components/expense_list_item.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/models/expense.dart';
import '../components/finance_button.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateinput = TextEditingController();
  String? expenseType;
  //DateTime? expenseTime;

  @override
  void initState() {
    dateinput.text = ""; //set the initial value of text field
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    DateTime now = DateTime.now();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Masraflar"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //select school
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        "Masraf Geçmişi",
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ),
                  ),
                  // expenses
                  Container(
                    width: size.width,
                    margin: const EdgeInsets.only(bottom: 10),
                    height: size.height * 0.35,
                    child: FutureBuilder<List<Expense>>(
                      future: getDriverExpense(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                                'Bir hata oluştu!\n${snapshot.error!.toString()}'),
                          );
                        } else if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text('Eklenen masraf yok!'),
                            );
                          }
                          return ListView(
                            children: [
                              for (var expense in snapshot.data!)
                                ExpenseListItem(
                                    title: expense.type,
                                    date: DateFormat("dd/MM/yy")
                                        .format(expense.date)
                                        .toString(),
                                    driver: "",
                                    amount: expense.amount,
                                    note: expense.description),
                            ],
                          );
                        } else {
                          return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.black),
                          );
                        }
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        "Masraf Ekle",
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ),
                  ),
                  SizedBox(
                      width: size.width,
                      height: size.height * 0.30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // ignore: prefer_const_literals_to_create_immutables
                        children: <Widget>[
                          Flexible(
                            child: SizedBox(
                              height: 75,
                              width: double.infinity,
                              child: DropdownGeneral(
                                searchable: false,
                                list: const [
                                  "Yakıt",
                                  "Yedek Parça",
                                  "Muhtelif",
                                  "Şahsi"
                                ],
                                width: MediaQuery.of(context).size.width * 0.70,
                                previewText: "Masraf Tipi",
                                onChanged: (p0) {
                                  setState(() {
                                    expenseType = p0 as String;
                                  });
                                },
                                selectedValue: expenseType,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Flexible(
                                  child: SizedBox(
                                height: 50,
                                child: TextField(
                                  controller: dateinput,
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
                                    labelStyle:
                                        TextStyle(color: COLOR_DARK_GREY),
                                  ),
                                  readOnly: true, //user wont able to edit text
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      lastDate: now,
                                      firstDate: now
                                          .subtract(const Duration(days: 30)),
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            colorScheme: ColorScheme.light(
                                                primary: COLOR_DARK_GREY),
                                            textButtonTheme:
                                                TextButtonThemeData(
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                    COLOR_DARK_GREY,
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
                                          DateFormat('dd/MM/yyyy')
                                              .format(pickedDate);
                                      print(formattedDate);

                                      setState(() {
                                        dateinput.text =
                                            formattedDate; //set output date to TextField value.
                                      });
                                    } else {
                                      print("Date is not selected");
                                    }
                                  },
                                ),
                              ) /* DateTimeFormField(
                                  decoration: const InputDecoration(
                                    hintStyle: TextStyle(color: COLOR_BLACK),
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.event_note),
                                    labelText: 'Tarih',
                                  ),
                                  dateFormat: DateFormat('d MMM y', 'tr'),
                                  lastDate: now,
                                  firstDate:
                                      now.subtract(const Duration(days: 30)),
                                  mode: DateTimeFieldPickerMode.date,
                                  autovalidateMode: AutovalidateMode.always,
                                  onDateSelected: (DateTime value) {
                                    expenseTime = value;
                                    print(value);
                                  },
                                ), */
                                  ),
                              const SizedBox(width: 10),
                              Flexible(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: SizedBox(
                                          height: 50,
                                          width: double.infinity,
                                          child: TextField(
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 5.0,
                                                      horizontal: 10),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: COLOR_LIGHT_GREY),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: COLOR_DARK_GREY),
                                              ),
                                              //border: OutlineInputBorder(),
                                              hintText: 'Tutar (₺)',
                                            ),
                                            controller: amountController,
                                          ))))
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: SizedBox(
                              width: double.infinity,
                              child: TextField(
                                keyboardType: TextInputType.multiline,
                                autocorrect: false,
                                maxLines: 2,
                                maxLength: 140,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: COLOR_LIGHT_GREY),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: COLOR_DARK_GREY),
                                  ),
                                  hintText: 'Açıklama',
                                ),
                                controller: descriptionController,
                              ),
                            ),
                          ),
                          FinanceButton(
                              onPressed: () {
                                if (expenseType == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Lütfen masraf tipi seçiniz!'),
                                    ),
                                  );
                                } else if (dateinput.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Lütfen tarih seçiniz!'),
                                    ),
                                  );
                                } else if (amountController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Lütfen tutar seçiniz!'),
                                    ),
                                  );
                                } else {
                                  addExpense(
                                      expenseType!,
                                      dateinput.text,
                                      amountController.text,
                                      descriptionController.text);
                                }
                              },
                              child: const Text("Masraf Ekle"))
                        ],
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void addExpense(
      String type, String date, String amount, String? description) async {
    var url = Uri.http(deployURL, 'driver/addExpense');
    print(url);
    //TODO: need to check if address and school type null or not
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'amount': amount,
      'expenseType': type,
      'date': date,
      'description': description,
      'phone': await getUserPhone()
    });

    final snackBar = SnackBar(
      content: const Text('Masraf eklendi.'),
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
        builder: (context) => ExpensePage(),
      ),
    );
  }

  Future<List<Expense>> getDriverExpense() async {
    var url = Uri.http(deployURL, 'driver/getDriverExpense');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'phone': await getUserPhone()
    });
    print(response.body);

    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<Expense>((json) => Expense.fromJson(json)).toList();
  }
}
