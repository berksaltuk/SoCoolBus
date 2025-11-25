import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_app/components/select_general.dart';
import 'package:my_app/components/select_month.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/driver/components/enter_payment_list.dart';
import 'package:my_app/models/payment.dart';
import 'package:http/http.dart' as http;
import '../../components/common_methods.dart';

class EnterPostponePayment extends StatefulWidget {
  const EnterPostponePayment({super.key});
  @override
  State<EnterPostponePayment> createState() => _EnterPostponePaymentState();
}

class _EnterPostponePaymentState extends State<EnterPostponePayment> {
  String selectedMonth = getCurrentMonthString();
  String selectedYear = DateTime.now().year.toString();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tahsilat Gir / Ertele"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Row(
                //mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonMonth(
                      onChange: (value) {
                        setState(() {
                          selectedMonth = value as String;
                        });
                      },
                      value: selectedMonth),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: size.height * 0.06,
                    child: DropdownGeneral(
                        width: size.width * 0.25,
                        list: const ["2023", "2024"],
                        onChanged: (value) {
                          setState(() {
                            selectedYear = value as String;
                          });
                        },
                        selectedValue: selectedYear,
                        searchable: false),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  "Ödeme Listesi",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black26,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.94,
                  height: MediaQuery.of(context).size.height * 0.66,
                  //height: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.all(Radius.circular(6))),

                  child: FutureBuilder<List<Payment>>(
                    future:
                        getDriverUnpaidPayments(selectedMonth, selectedYear),
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
                        return ListView(
                          children: [
                            for (var payment in snapshot.data!)
                              EnterPaymentListItem(
                                paymentId: payment.paymentId,
                                title: "Ödeme Tutarı: ${payment.paidAmount}",
                                user: payment.paidBy,
                                paymentAmount: payment.leftAmount,
                                paymentInfo: "Kalan",
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
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Payment>> getDriverUnpaidPayments(
      String? selectedMonth, String? selectedYear) async {
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
    int year = int.parse(selectedYear!);
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
}
