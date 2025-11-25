import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/components/select_general.dart';
import 'package:my_app/constants.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/driver/components/finance_button.dart';

class SubscribePage extends StatefulWidget {
  DateTime? endDate;
  SubscribePage({super.key, required this.endDate});

  @override
  State<SubscribePage> createState() => _SubscribePageState();
}

class _SubscribePageState extends State<SubscribePage> {
  int choice = 1;
  String selectedSchoolNumber = "3";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    DateTime date = widget.endDate ?? DateTime.now();
    if (date.isBefore(DateTime.now())) {
      date = DateTime.now();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Üyelik / Ödeme"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            const SizedBox(height: 10),
            const Text("Belirlenen okul sayısı"),
            DropdownGeneral(
                list: const ["1", "3", "5", "10", "20", "30"],
                onChanged: (p0) {
                  setState(() {
                    selectedSchoolNumber = p0!;
                  });
                },
                selectedValue: selectedSchoolNumber,
                previewText: "Okul Sayısı",
                searchable: false),
            const SizedBox(height: 10),
            // expenses
            SingleChildScrollView(
              child: Container(
                width: size.width,
                margin: const EdgeInsets.only(bottom: 10),
                height: size.height * 0.6,
                child: FutureBuilder<dynamic>(
                  future: calculateFee(selectedSchoolNumber),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                            'Bir hata oluştu!\n${snapshot.error!.toString()}'),
                      );
                    } else if (snapshot.hasData) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Center(
                            child: Text("Ödeme Planları"),
                          ),
                          RadioListTile<int>(
                            title: Text('${snapshot.data![0]}₺ / 1 Ay'),
                            activeColor: Colors.orange,
                            value: 1,
                            groupValue: choice,
                            onChanged: (int? value) {
                              setState(() {
                                choice = value!;
                              });
                            },
                          ),
                          RadioListTile<int>(
                            title: Text('${snapshot.data![1]}₺ / 3 Ay'),
                            activeColor: Colors.orange,
                            value: 2,
                            groupValue: choice,
                            onChanged: (int? value) {
                              setState(() {
                                choice = value!;
                              });
                            },
                          ),
                          RadioListTile<int>(
                            title: Text('${snapshot.data![2]}₺ / 9 Ay'),
                            activeColor: Colors.orange,
                            value: 3,
                            groupValue: choice,
                            onChanged: (int? value) {
                              setState(() {
                                choice = value!;
                              });
                            },
                          ),
                          RadioListTile<int>(
                            title: Text('${snapshot.data![3]}₺ / 12 Ay'),
                            activeColor: Colors.orange,
                            value: 4,
                            groupValue: choice,
                            onChanged: (int? value) {
                              setState(() {
                                choice = value!;
                              });
                            },
                          ),
                          const Center(
                            child: Text(
                              "* Okul sayısına göre fiyatlandırılır. KDV dahildir.",
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          Container(
                            width: size.width,
                            margin: const EdgeInsets.only(bottom: 10),
                            height: size.height * 0.2,
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
                                        border: Border.all(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_month),
                                        const Text("Üyelik Başlama Tarihi"),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(DateFormat('d/MM/yyyy')
                                                .format(date)),
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
                                        const Icon(Icons.calendar_month),
                                        const Text("  Üyelik Bitiş Tarihi"),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(DateFormat('d/MM/yyyy')
                                                .format(
                                                    getEndTime(choice, date))),
                                          ),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          FinanceButton(
                            onPressed: () {
                              subscribe(selectedSchoolNumber, choice);
                            },
                            child: Text(
                              'Ödeme Adımına Geç',
                              style: Theme.of(context).textTheme.headline3,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      );
                    }
                  },
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<dynamic> calculateFee(String selectedSchoolNumber) async {
    int oneMonthCost;
    int threeMonthCost;
    int nineMonthCost;
    int twelveMonthCost;
    var url = Uri.http(deployURL, 'driver/calculateSubscriptionCost');
    print(url);

    var response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'schoolNumber': selectedSchoolNumber,
      'lengthInMonths': '1',
    });
    oneMonthCost = jsonDecode(response.body)['cost'];

    response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'schoolNumber': selectedSchoolNumber,
      'lengthInMonths': '3',
    });
    threeMonthCost = jsonDecode(response.body)['cost'];

    response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'schoolNumber': selectedSchoolNumber,
      'lengthInMonths': '9',
    });
    nineMonthCost = jsonDecode(response.body)['cost'];

    response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'schoolNumber': selectedSchoolNumber,
      'lengthInMonths': '12',
    });
    twelveMonthCost = jsonDecode(response.body)['cost'];

    return [oneMonthCost, threeMonthCost, nineMonthCost, twelveMonthCost];
  }

  DateTime getEndTime(int choice, DateTime endDate) {
    if (choice == 1) {
      return endDate.add(const Duration(days: 30));
    } else if (choice == 2) {
      return endDate.add(const Duration(days: 90));
    } else if (choice == 3) {
      return endDate.add(const Duration(days: 270));
    } else if (choice == 4) {
      return endDate.add(const Duration(days: 365));
    } else {
      return endDate;
    }
  }

  void subscribe(String selectedSchoolNumber, int choice) async {
    var url = Uri.http(deployURL, 'driver/startSubscription');
    Map<int, String> choiceToMonths = {
      1: "1",
      2: "3",
      3: "9",
      4: "12",
    };
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'driverPhone': await getUserPhone(),
      'schoolNumber': selectedSchoolNumber,
      'lengthInMonths': choiceToMonths[choice],
    });
    print(response.body);
    if (response.statusCode == 200) {
      final snackBar = SnackBar(
        content: const Text('Üyelik başarılı. Teşekkür ederiz.'),
        action: SnackBarAction(
          label: '',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      Navigator.pop(context);
    } else {
      final snackBar = SnackBar(
        content: const Text('Üyelik başarısız!'),
        action: SnackBarAction(
          label: '',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
