import 'dart:convert';
import 'dart:io';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/components/general_button.dart';
import 'package:my_app/components/pdf_view.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/driver/components/expense_report_list_item.dart';
import 'package:my_app/models/payment_report_expense.dart';
import 'package:http/http.dart' as http;

class ExpenseReportPage extends StatefulWidget {
  const ExpenseReportPage({super.key});

  @override
  State<ExpenseReportPage> createState() => _ExpenseReportPageState();
}

class _ExpenseReportPageState extends State<ExpenseReportPage> {
  DateTime startTime = DateTime.now().subtract(const Duration(days: 30));
  DateTime endTime = DateTime.now();
  String? _payload;
  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gider Raporları"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          child: ListView(
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    child: DateTimeFormField(
                      initialDate: startTime,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(color: Colors.black45),
                        errorStyle: TextStyle(color: Colors.redAccent),
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.event_note),
                        labelText: 'Başlangıç',
                      ),
                      dateFormat: DateFormat('d MMM y', 'tr'),
                      firstDate:
                          DateUtils.dateOnly(DateTime.now().subtract(const Duration(days: 1000))),
                      lastDate: now,
                      mode: DateTimeFieldPickerMode.date,
                      autovalidateMode: AutovalidateMode.always,
                      onDateSelected: (DateTime value) {
                        startTime = value;
                        print(value);
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: DateTimeFormField(
                      initialValue: endTime,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(color: Colors.black45),
                        errorStyle: TextStyle(color: Colors.redAccent),
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.event_note),
                        labelText: 'Bitiş',
                      ),
                      dateFormat: DateFormat('d MMM y', 'tr'),
                      firstDate: startTime,
                      lastDate: now,
                      mode: DateTimeFieldPickerMode.date,
                      autovalidateMode: AutovalidateMode.always,
                      onDateSelected: (DateTime value) {
                        endTime = value;
                        print(value);
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        "Rapor Listesi",
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: COLOR_WHITE),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              flex: 1,
                              child: SizedBox(
                                child: Column(
                                  children: const [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Masraf Kalemi",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: SizedBox(
                                child: Column(
                                  children: const [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Tarih',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: SizedBox(
                                child: Column(
                                  children: const [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Masraf",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: SizedBox(
                                child: Column(
                                  children: const [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Açıklama",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Container(
                      width: size.width,
                      height: size.height * 0.3,
                      child: FutureBuilder<List<ExpenseReport>>(
                        future: getDriverPaymentReport(startTime, endTime),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                  'Bir hata oluştu!\n${snapshot.error!.toString()}'),
                            );
                          } else if (snapshot.hasData) {
                            if (snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text('Gösterilebilecek veri yok.'),
                              );
                            }
                            return ListView(
                              children: [
                                for (var payment in snapshot.data!)
                                  ExpenseReportListItem(
                                    type: payment.type,
                                    date: payment.date,
                                    description: payment.description,
                                    amount: payment.amount.toString(),
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
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    "Genel Tablo",
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: size.height * 0.23,
                child: Column(children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: FutureBuilder<List<dynamic>>(
                      future: getDriverExpanseReportSummary(startTime, endTime),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                                'Bir hata oluştu!\n${snapshot.error!.toString()}'),
                          );
                        } else if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text('Gösterilebilecek veri yok.'),
                            );
                          }
                          return Column(
                            children: [
                              for (var expanse in snapshot.data!)
                                Container(
                                  height: size.height * 0.06,
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: COLOR_WHITE,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        expanse['_id'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2,
                                      ),
                                      Text(
                                        "${expanse['totalAmount']} ₺",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2,
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(
                                height: size.height * 0.01,
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
                ]),
              ),
              GeneralButton(
                  onPressed: () async {
                    getPDFReport().then((value) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PDFViewerScreen(
                                  pdfData: value,
                                )),
                      );
                    });
                  },
                  child: const Text("PDF Rapor Al")),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<ExpenseReport>> getDriverPaymentReport(
      DateTime startTime, DateTime endTime) async {
    var url = Uri.http(deployURL, 'report/expenseReport');
    print(url);

    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'driverPhone': await getUserPhone(),
      'fromDate': startTime.toUtc().toString(),
      'toDate': endTime.toUtc().toString(),
    });
    print(response.body);
    _payload = response.body;
    final parsed =
        jsonDecode(response.body)['result'].cast<Map<dynamic, dynamic>>();
    print(parsed);

    return parsed
        .map<ExpenseReport>((json) => ExpenseReport.fromJson(json))
        .toList();
  }

  Future<List<dynamic>> getDriverExpanseReportSummary(
      DateTime startTime, DateTime endTime) async {
    var url = Uri.http(deployURL, 'report/expenseReport');
    print(url);

    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'driverPhone': await getUserPhone(),
      'fromDate': startTime.toUtc().toString(),
      'toDate': endTime.toUtc().toString(),
    });
    print(response.body);
    final parsed =
        jsonDecode(response.body)['summary'].cast<Map<dynamic, dynamic>>();
    return parsed;
  }

  Future<Uint8List> getPDFReport() async {
    var url = Uri.http(deployURL, 'report/generatePDF');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'payload': _payload
    });
    print(response.body);

    return response.bodyBytes;
  }
}
