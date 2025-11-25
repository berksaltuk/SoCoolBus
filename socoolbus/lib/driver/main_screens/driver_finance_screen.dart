import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/driver/components/driver_finance_list.dart';
import 'package:my_app/driver/components/finance_button.dart';
import 'package:my_app/driver/sub_finance/driver_enter_postpone_payment_screen.dart';
import 'package:my_app/driver/sub_finance/expense_page.dart';
import 'package:my_app/driver/sub_finance/make_raise.dart';
import 'package:my_app/driver/sub_finance/payment_list_page.dart';
import 'package:my_app/driver/sub_finance/request_payment_page.dart';
import 'package:my_app/driver/sub_finance/select_due_date.dart';
import 'package:my_app/driver/sub_finance/share_payment_method_page.dart';
import 'package:my_app/models/finance_agenda_entry.dart';
import 'package:http/http.dart' as http;

import '../../components/common_methods.dart';

class DriverFinanceScreen extends StatelessWidget {
  const DriverFinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          // ignore: prefer_const_constructors
          title: Text(
            'Finans',
            style: const TextStyle(fontSize: 20),
          ),
          automaticallyImplyLeading: false,
          //actions: const [ChangeSchool()], This enables the school change in the top right corner
        ),
        body: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //title
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Gündem",
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ),
                  ),
                  //scrollable list
                  SingleChildScrollView(
                    child: Container(
                      width: size.width,
                      margin: const EdgeInsets.only(bottom: 10),
                      height: size.height * 0.26,
                      child: FutureBuilder<List<FinanceAgandaEntry>>(
                        future: getDriverFinanceAgenda(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                  'Bir hata oluştu!\n${snapshot.error!.toString()}'),
                            );
                          } else if (snapshot.hasData) {
                            if (snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text('Finans gündemi yok!'),
                              );
                            }
                            return ListView(
                              children: [
                                for (var agenda in snapshot.data!)
                                  FinanceList(
                                    name: agenda.mainHeader,
                                    operation: agenda.summary,
                                    amount: agenda.amount,
                                    status: agenda.status,
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
                  ),
                  //operations
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "İşlemler",
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        width: size.width,
                        margin: const EdgeInsets.only(bottom: 10),
                        height: size.height * 0.39,
                        child: Column(
                          children: [
                            FinanceButton(
                              //navigate to payment list page
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PaymentListPage()),
                                );
                              },
                              child: Text(
                                'Tahsilat Listesi Görüntüle',
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            ),
                            SizedBox(height: size.height * 0.001),
                            FinanceButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SelectDueDate()),
                                );
                              },
                              child: Text(
                                'Tahsilat Tarihi Belirle',
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            ),
                            SizedBox(height: size.height * 0.001),
                            FinanceButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MakeRaiseScreen()),
                                );
                              },
                              child: Text(
                                'Zam Yap',
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            ),
                            SizedBox(height: size.height * 0.001),
                            FinanceButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const EnterPostponePayment()),
                                );
                              },
                              child: Text(
                                'Tahsilat Gir/Ertele',
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            ),
                            SizedBox(height: size.height * 0.001),
                            FinanceButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RequestPaymentPage()),
                                );
                              },
                              child: Text(
                                'Tahsilat İste',
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            ),
                            SizedBox(height: size.height * 0.001),
                            FinanceButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SharePaymentMethodPage()),
                                );
                              },
                              child: Text(
                                'Ödeme Yöntemi Paylaş',
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            ),
                            SizedBox(height: size.height * 0.001),
                            FinanceButton(
                              //navigate to payment list page
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ExpensePage()),
                                );
                              },
                              child: Text(
                                'Masraflar',
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<FinanceAgandaEntry>> getDriverFinanceAgenda() async {
    var url = Uri.http(deployURL, 'driver/getFinancialAgenda');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'driverPhone': await getUserPhone()
    });
    print(response.body);

    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    return parsed
        .map<FinanceAgandaEntry>((json) => FinanceAgandaEntry.fromJson(json))
        .toList();
  }
}
