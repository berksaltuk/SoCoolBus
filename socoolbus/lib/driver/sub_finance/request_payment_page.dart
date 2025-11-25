import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/components/select_general.dart';
import 'package:my_app/components/select_month.dart';
import 'package:my_app/driver/components/request_payment_list.dart';
import 'package:my_app/models/payment.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';

class RequestPaymentPage extends StatefulWidget {
  const RequestPaymentPage({super.key});

  @override
  State<RequestPaymentPage> createState() => _RequestPaymentPageState();
}

class _RequestPaymentPageState extends State<RequestPaymentPage> {
  String selectedMonth = getCurrentMonthString();
  String selectedYear = DateTime.now().year.toString();
  Map<String, bool> paymentIdsToCheckboxState = {};

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tahsilat İste"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      "Öğrenci Listesi",
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          DropdownButtonMonth(
                            onChange: (value) {
                              setState(() {
                                selectedMonth = value as String;
                                paymentIdsToCheckboxState.clear();
                              });
                            },
                            value: selectedMonth,
                          ),
                          SizedBox(
                            width: size.width * 0.05,
                          ),
                          DropdownGeneral(
                              width: MediaQuery.of(context).size.width * 0.25,
                              list: const ["2023", "2024"],
                              onChanged: (value) {
                                setState(() {
                                  selectedYear = value as String;
                                });
                              },
                              selectedValue: selectedYear,
                              searchable: false),
                        ],
                      ),
                      SingleChildScrollView(
                        child: SizedBox(
                          width: size.width,
                          height: size.height * 0.30,
                          child: FutureBuilder<List<Payment>>(
                            future: getDriverUnpaidPayments(
                                selectedMonth, selectedYear),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                      'Bir hata oluştu!\n${snapshot.error!.toString()}'),
                                );
                              } else if (snapshot.hasData) {
                                if (snapshot.data!.isEmpty) {
                                  return const Center(
                                    child: Text(
                                        'Bu ay ve okul için tahsilatınız bulunmuyor.'),
                                  );
                                }
                                List<bool> checkList = List.generate(
                                  snapshot.data!.length,
                                  (index) {
                                    Payment payment = snapshot.data![index];

                                    // Use the payment id to get the saved checkbox state from the Map
                                    bool isChecked = paymentIdsToCheckboxState[
                                            payment.paymentId] ??
                                        false;

                                    // Return the initial checkbox state
                                    return isChecked;
                                  },
                                );
                                return ListView(
                                  children: [
                                    for (var entry
                                        in snapshot.data!.asMap().entries)
                                      RequestPaymentListItem(
                                          check: Checkbox(
                                              value: checkList[entry.key],
                                              activeColor: Colors.amber,
                                              onChanged: (e) {
                                                setState(() {
                                                  paymentIdsToCheckboxState[
                                                      entry.value
                                                          .paymentId] = e!;
                                                });
                                              }),
                                          name: entry.value.paidBy,
                                          installmentInfo:
                                              entry.value.paymentNumber,
                                          amount: entry.value.leftAmount,
                                          status: entry.value.status),
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
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 5.0,
                        textStyle: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      askForPayment();
                    },
                    child: const Text("SMS Gönder"),
                  ),
                ),
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: FutureBuilder<dynamic>(
                            future: getBottomTable(selectedMonth, selectedYear),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                      'Bir hata oluştu!\n${snapshot.error!.toString()}'),
                                );
                              } else if (snapshot.hasData) {
                                return Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: COLOR_WHITE,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              "${snapshot.data['schoolName']} Tahsilat",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline2,
                                            ),
                                          ),
                                          Text(
                                            "${snapshot.data['totalIncomeSoFar']}₺",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: COLOR_WHITE,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              "${snapshot.data['schoolName']} Ödeyecekler",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline2,
                                            ),
                                          ),
                                          Text(
                                            "${snapshot.data['totalExpectedIncome']}₺",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: COLOR_WHITE,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              "${snapshot.data['schoolName']} Toplam",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline2,
                                            ),
                                          ),
                                          Text(
                                            "${snapshot.data['amountToBeCollected']}₺",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: COLOR_WHITE,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Tüm Okullar Tahsilat",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline2,
                                          ),
                                          Text(
                                            "${snapshot.data['totalExpectedIncomeAllSchools']}₺",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.black),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Payment>> getDriverUnpaidPayments(
      String selectedMonth, String selectedYear) async {
    var url = Uri.http(deployURL, 'driver/viewUnpaidPayments');
    Map<String, int> monthToInt = {
      'Ocak': 1,
      'Şubat': 2,
      'Mart': 3,
      'Nisan': 4,
      'Mayıs': 5,
      'Haziran': 6,
      'Temmuz': 7,
      'Ağustos': 8,
      'Eylül': 9,
      'Ekim': 10,
      'Kasım': 11,
      'Aralık': 12,
    };
    int year = int.parse(selectedYear);
    int? monthInt = monthToInt[selectedMonth];
    DateTime fromDate = DateTime(year, monthInt!, 1);
    DateTime toDate = DateTime(year, monthInt + 1, 1);

    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'phone': await getUserPhone(),
      'school': await getSelectedSchool(),
      'fromDate': fromDate.toUtc().toString(),
      'toDate': toDate.toUtc().toString(),
    });
    print(response.body);

    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<Payment>((json) => Payment.fromJson(json)).toList();
  }

  void askForPayment() async {
    var url = Uri.http(deployURL, 'sms/askForPayment');
    List<String> paymentIds = paymentIdsToCheckboxState.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();
    print(url);
    print(paymentIds);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'paymentIDs': paymentIds.toString(),
    });
    print(response.body);
  }

  Future<dynamic> getBottomTable(
      String selectedMonth, String selectedYear) async {
    var url = Uri.http(deployURL, 'driver/calculateIncomeBySchool');
    print(url);

    Map<String, int> monthToInt = {
      'Ocak': 1,
      'Şubat': 2,
      'Mart': 3,
      'Nisan': 4,
      'Mayıs': 5,
      'Haziran': 6,
      'Temmuz': 7,
      'Ağustos': 8,
      'Eylül': 9,
      'Ekim': 10,
      'Kasım': 11,
      'Aralık': 12,
    };
    int year = int.parse(selectedYear);
    int? monthInt = monthToInt[selectedMonth];
    DateTime fromDate = DateTime(year, monthInt!, 1);
    DateTime toDate = DateTime(year, monthInt + 1, 1);

    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      "phone": await getUserPhone(),
      "school": await getSelectedSchool(),
      "fromDate": fromDate.toUtc().toString(),
      "toDate": toDate.toUtc().toString(),
    });
    print(response.body);
    return jsonDecode(response.body);
  }
}
