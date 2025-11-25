import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/driver/settings/subscription_subpages/old_subscriptions.dart';
import 'package:my_app/driver/settings/subscription_subpages/subscribe.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  DateTime? _subStartTime;
  DateTime? _subEndTime;
  int? _month;
  int? _subSchool;
  bool _isLoaded = false;

  @override
  initState() {
    getSubscribtionDetails().then((result) {
      _subStartTime = DateTime.parse(result['starts']);
      _subEndTime = DateTime.parse(result['ends']);
      _month = result['lengthInMonths'];
      _subSchool = result['maxSchoolNumber'];
      setState(() {
        _isLoaded = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
            onWillPop: () async => true,
            child: Scaffold(
              appBar: AppBar(
                // ignore: prefer_const_constructors
                title: Text(
                  'Üyelik / Hesap Bilgileri',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              body: _isLoaded ?
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //scrollable list
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              width: size.width,
                              margin: const EdgeInsets.only(bottom: 10),
                              height: size.height * 0.63,
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                children: [
                                  Container(
                                      width: size.width,
                                      margin: const EdgeInsets.only(bottom: 10),
                                      height: size.height * 0.0752,
                                      padding: const EdgeInsets.all(22.0),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_month),
                                          const Text("  Üyelik Başlama Tarihi"),
                                          Expanded(
                                            child: Container(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                  DateFormat('d/MM/yyyy')
                                                      .format(_subStartTime!)),
                                            ),
                                          ),
                                        ],
                                      )),
                                  Container(
                                      width: size.width,
                                      margin: const EdgeInsets.only(bottom: 10),
                                      height: size.height * 0.0752,
                                      padding: const EdgeInsets.all(22.0),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_month),
                                          const Text("  Üyelik Bitiş Tarihi"),
                                          Expanded(
                                            child: Container(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                  DateFormat('d/MM/yyyy')
                                                      .format(_subEndTime!)),
                                            ),
                                          ),
                                        ],
                                      )),
                                  Container(
                                    width: size.width,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    height: size.height * 0.0752,
                                    padding: const EdgeInsets.all(22.0),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.timer),
                                        const Text("  Üyelik Süresi"),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child:
                                                Text("${_month?.toString() ?? "<1"} Ay"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                      width: size.width,
                                      margin: const EdgeInsets.only(bottom: 10),
                                      height: size.height * 0.0752,
                                      padding: const EdgeInsets.all(22.0),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.apartment),
                                          const Text("  Maksimum Okul Sayısı"),
                                          Expanded(
                                            child: Container(
                                              alignment: Alignment.centerRight,
                                              child:
                                                  Text(_subSchool.toString()),
                                            ),
                                          ),
                                        ],
                                      )),
                                  Container(
                                    width: size.width,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    height: size.height * 0.0752,
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: MaterialButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const OldSubscriptionPage()),
                                          );
                                        },
                                        child: Row(
                                          children: const [
                                            Icon(Icons.payments),
                                            Text("  Geçmiş Ödemeler"),
                                          ],
                                        )),
                                  ),
                                  Container(
                                    width: size.width,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    height: size.height * 0.0752,
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: MaterialButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SubscribePage(endDate: _subEndTime)),
                                          );
                                        },
                                        child: Row(
                                          children: const [
                                            Icon(Icons.payment),
                                            Text("  Üyelik & Ödeme"),
                                          ],
                                        )),
                                  ),
                                  Container(
                                    width: size.width,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    height: size.height * 0.0752,
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: MaterialButton(
                                        onPressed: () {},
                                        child: Row(
                                          children: const [
                                            Icon(Icons.wallet_giftcard),
                                            Text("  Kampanyalar"),
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ) :  const Center(child: CircularProgressIndicator(color: Colors.black))
            ),
          );
  }

  Future<dynamic> getSubscribtionDetails() async {
    var url = Uri.http(deployURL, 'driver/getSubscriptionDetails');
    print(url);

    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'driverPhone': await getUserPhone(),
    });
    print(response.body);
    return jsonDecode(response.body);
  }
}
