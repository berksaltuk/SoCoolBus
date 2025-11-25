import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/components/select_general.dart';
import 'package:my_app/components/select_month.dart';
import 'package:my_app/driver/components/payment_list_item.dart';
import 'package:my_app/models/payment.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';

class PaymentListPage extends StatefulWidget {
  const PaymentListPage({super.key});

  @override
  State<PaymentListPage> createState() => _PaymentListPageState();
}

class _PaymentListPageState extends State<PaymentListPage> {
  String selectedMonth = getCurrentMonthString();
  String selectedYear = DateTime.now().year.toString();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool thisMonthHasNoPayment = false;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Tahsilat Listesi/Durumu"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //select school

                const SizedBox(
                  height: 10,
                ),
                Column(
                  children: [
                    Container(
                      child: Row(
                        children: [
                          DropdownButtonMonth(
                            onChange: (value) {
                              setState(() {
                                selectedMonth = value as String;
                              });
                            },
                            value: selectedMonth,
                          ),
                          const SizedBox(
                            width: 10,
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
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          "Tahsilat Listesi",
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Container(
                        width: size.width,
                        height: size.height * 0.34,
                        child: FutureBuilder<List<Payment>>(
                          future:
                              getDriverPayments(selectedMonth, selectedYear),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                    'Bir hata oluştu!\n${snapshot.error!.toString()}'),
                              );
                            } else if (snapshot.hasData) {
                              if (snapshot.data!.isEmpty) {
                                thisMonthHasNoPayment = true;
                                return const Center(
                                  child: Text(
                                      'Bu ay ve okul için tahsilatınız bulunmuyor.'),
                                );
                              }
                              return ListView(
                                children: [
                                  for (var payment in snapshot.data!)
                                    PaymentListItem(
                                        name: payment.paidBy,
                                        paymentNumber: payment.paymentNumber,
                                        amount: payment.totalAmount,
                                        status: payment.status),
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
                      "Tahsilat Durumu",
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: size.height * 0.23,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: FutureBuilder<List<int>>(
                          future: getDriverIncome(selectedMonth, selectedYear),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Center(
                                child: Text(
                                    'Bu ay ve okul için tahsilatınız bulunmuyor.'),
                              );
                            } else if (snapshot.hasData) {
                              return Column(
                                children: [
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
                                          "Tüm Okullar Gelir",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline2,
                                        ),
                                        Text(
                                          "${snapshot.data![0]} ₺",
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
                                          "Tüm Okullar Tahsilat",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline2,
                                        ),
                                        Text(
                                          "${snapshot.data![1]} ₺",
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
                                          "Tüm Okullar Ödeyecekler",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline2,
                                        ),
                                        Text(
                                          "${snapshot.data![2]} ₺",
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
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Future<List<Payment>> getDriverPayments(
      String? selectedMonth, String selectedYear) async {
    var url = Uri.http(deployURL, 'driver/viewPayments');
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
    int? monthInt = monthToInt[selectedMonth!];
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

  Future<List<int>> getDriverIncome(
      String? selectedMonth, String selectedYear) async {
    List<int> incomeTypes = [];
    var url = Uri.http(deployURL, 'driver/calculateIncome');
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
    int? monthInt = monthToInt[selectedMonth!];
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
    final parsed = jsonDecode(jsonEncode(jsonDecode(response.body)[0]));
    print("parsed");
    print(parsed);
    incomeTypes.add(parsed["totalExpectedIncome"].toInt());
    incomeTypes.add(parsed["totalIncomeSoFar"].toInt());
    incomeTypes.add(parsed["amountToBeCollected"].toInt());
    print("object");
    print(incomeTypes);
    return incomeTypes;
  }
}
