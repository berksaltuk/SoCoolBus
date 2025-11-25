import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/components/general_button.dart';
import 'package:my_app/components/pdf_view.dart';
import 'package:my_app/components/select_general.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/driver/components/payment_report_list_item.dart';
import 'package:my_app/driver/components/select_school.dart';
import 'package:my_app/models/payment_report_income.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/models/school.dart';

class IncomeReportPage extends StatefulWidget {
  const IncomeReportPage({super.key});

  @override
  State<IncomeReportPage> createState() => _IncomeReportPageState();
}

class _IncomeReportPageState extends State<IncomeReportPage> {
  String type = "Okul Bazında";
  School? selectedSchool;
  String? _payload;
  List<int> _summary = [0,0,0];

  @override
  void initState() {
    getDriverSchools(getUserPhone()).then(
      (value) async {
        if ((await getSelectedSchool()) == null) {
          setSelectedSchool(value.first.schoolId);
          selectedSchool = value.first;
        } else {
          findSchoolById((await getSelectedSchool())!).then((value) {
            selectedSchool = value;
          });
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gelir Raporları"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          child: ListView(
            children: [
              DropdownGeneral(
                  list: const ["Okul Bazında", "Öğrenci Bazında"],
                  onChanged: (p0) {
                    setState(() {
                      type = p0!;
                    });
                  },
                  selectedValue: type,
                  searchable: false),
              type == "Öğrenci Bazında"
                  ? FutureBuilder<List<School>>(
                      future: getDriverSchools(getUserPhone()),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('Bir hata oluştu!'),
                          );
                        } else if (snapshot.hasData) {
                          return DropdownButtonSchool(
                            list: snapshot.data!,
                            //width: MediaQuery.of(context).size.width * 0.70,
                            previewText: "Okul Seç",
                            searchText: "Okul Ara",
                            onChanged: (p0) {
                              setState(() {
                                selectedSchool = p0;
                              });
                            },
                            selectedValue: selectedSchool,
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    )
                  : const SizedBox(),
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
                                        "Ad",
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
                                        'Ay',
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
                                        "Yıllık",
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
                                        "Tahsilat",
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
                                        "Kalan",
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
                      child: FutureBuilder<List<PaymentReport>>(
                        future: getDriverPaymentReport(type, selectedSchool),
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
                                  PaymentReportListItem(
                                    name: payment.name,
                                    month: payment.serviceTimeInMonths,
                                    yearlyFee: (payment.totalAmount).toString(),
                                    paid: (payment.paidAmount).toString(),
                                    remainingFee:
                                        (payment.leftAmount).toString(),
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
                    child: Column(
                      children: [
                        Container(
                          height: size.height * 0.06,
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: COLOR_WHITE,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Tüm Okullar Gelir",
                                style: Theme.of(context).textTheme.headline2,
                              ),
                              Text(
                                "${_summary[0]} ₺",
                                style: Theme.of(context).textTheme.headline2,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Tüm Okullar Tahsilat",
                                style: Theme.of(context).textTheme.headline2,
                              ),
                              Text(
                                "${_summary[1]} ₺",
                                style: Theme.of(context).textTheme.headline2,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Tüm Okullar Ödeyecekler",
                                style: Theme.of(context).textTheme.headline2,
                              ),
                              Text(
                                "${_summary[2]} ₺",
                                style: Theme.of(context).textTheme.headline2,
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Future<List<PaymentReport>> getDriverPaymentReport(
      String type, School? selectedSchool) async {
    var url;
    if (selectedSchool == null) {
      return [];
    }
    if (type == "Okul Bazında") {
      url = Uri.http(deployURL, 'report/incomeReportBySchool');
    } else {
      url = Uri.http(deployURL, 'report/incomeReportByStudent');
    }
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'driverPhone': await getUserPhone(),
      'schoolID': selectedSchool.schoolId,
    });
    print(response.body);
    _payload = response.body;

    final parsed =
        jsonDecode(response.body)['result'].cast<Map<dynamic, dynamic>>();
    final summary =
        jsonDecode(response.body)['summary'];
    

    _summary[0] = summary['totalExpectedIncome'].toInt();
    _summary[1] = summary['totalIncomeSoFar'].toInt();
    _summary[2] = summary['amountToBeCollected'].toInt();

    return parsed
        .map<PaymentReport>((json) => PaymentReport.fromJson(json))
        .toList();
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
