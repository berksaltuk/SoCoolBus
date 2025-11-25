import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/auth/login.dart';
import 'package:my_app/components/select_month.dart';
import 'package:my_app/driver/settings/update_password.dart';
import 'package:my_app/parent/components/payment_table_item.dart';
import 'package:my_app/parent/components/payment_table_tappable.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:my_app/constants.dart';

int count = 0;

class ParentPaymentScreen extends StatefulWidget {
  const ParentPaymentScreen({super.key});

  State<ParentPaymentScreen> createState() => _ParentPaymentState();
}

Widget button() {
  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  return Center(
    child: Column(
      children: <Widget>[
        ElevatedButton(
          style: style,
          onPressed: () {},
          child: const Text('Ödeme yap'),
        ),
      ],
    ),
  );
}

Widget helloDart2() {
  return DataTable(
    columnSpacing: 7,
    columns: const <DataColumn>[
      DataColumn(
        label: Expanded(
          child: Text(
            'Ödeme Ayı',
            style: TextStyle(fontStyle: FontStyle.normal),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Öğrenci Adı',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ),
      /*DataColumn(
          label: Expanded(
            child: Text(
              'Durumu',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ),*/
      DataColumn(
        label: Expanded(
          child: Text(
            'Gecikme',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Ücret',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Ödeme Yap',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ),
    ],
    rows: <DataRow>[
      DataRow(
        cells: <DataCell>[
          const DataCell(Text(
            'Kasım',
            style: TextStyle(fontSize: 20),
          )),
          const DataCell(Text('Arda Çelik')),
          //DataCell(Text('Yapılmadı')),
          const DataCell(Text('3 Gün')),
          const DataCell(Text('300')),
          DataCell(button()),
        ],
      ),
      DataRow(
        cells: <DataCell>[
          const DataCell(Text(
            'Kasım',
            style: TextStyle(fontSize: 20),
          )),
          const DataCell(Text('Derin Karaoğlu')),
          //DataCell(Text('Yapıldı')),
          const DataCell(Text('0 Gün')),
          const DataCell(Text('800')),
          DataCell(button()),
        ],
      ),
      DataRow(
        cells: <DataCell>[
          const DataCell(Text(
            'Ekim',
            style: TextStyle(fontSize: 20),
          )),
          const DataCell(Text('Arda Çelik')),
          //DataCell(Text('Yapıldı')),
          const DataCell(Text('0 Gün')),
          const DataCell(Text('300')),
          DataCell(button()),
        ],
      ),
      DataRow(
        cells: <DataCell>[
          const DataCell(Text(
            'Ekim',
            style: TextStyle(fontSize: 20),
          )),
          const DataCell(Text('Derin Karaoğlu')),
          //DataCell(Text('Ertelendi')),
          const DataCell(Text('0 Gün')),
          const DataCell(Text('0')),
          DataCell(button()),
          //DataCell(IconButton(onPressed: (() => {}), icon: Image.asset("assets/sy_logo.jpeg", fit: BoxFit.contain))),
        ],
      ),
    ],
  );
}

class _ParentPaymentState extends State<ParentPaymentScreen> {
  String? selectedMonth = 'Ocak';

  List<Map<String, String>> _values = [];
  bool _isLoaded = false;

  @override
  void initState() {
    getPaymentTable().then((value) {
      _values = value;
      setState(() {
        // _userTypes = value;
        _isLoaded = true;
      });
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return _isLoaded
        ? Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Image.asset("assets/images/sy_logo.jpeg",
                    fit: BoxFit.contain),
                onPressed: () => {},
              ),
              title: const Text("Ödemeler"),
              actions: [
                IconButton(
                    onPressed: (() {
                      FirebaseAuth.instance.signOut().then((val) {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => LoginPage()),
                            (Route<dynamic> route) => false);
                      });
                    }),
                    icon: const Icon(Icons.logout, color: Colors.red))
              ],
            ),
            body: Column(
              children: [
                const SizedBox(
                  height: 5,
                ),
                Text(
                  "Genel Ödeme Tablosu",
                  style: Theme.of(context).textTheme.headline1,
                  textAlign: TextAlign.center,
                ),
                SingleChildScrollView(
                  child: Container(
                    width: size.width,
                    height: size.height * 0.2,
                    child: ListView(
                      children: [
                        for (var item in _values)
                          PaymentTableItem(
                            name: item['name'],
                            contract: item['month'],
                            monthly: int.parse((item['monthly'] ?? "-6")),
                            amount: int.parse((item['price'] ?? "-1")),
                            status: item['status'] ?? "unpaid",
                          )
                      ],
                    ),
                  ),
                ),
                DropdownButtonMonth(
                    onChange: (value) {
                      setState(() {
                        selectedMonth = value as String;
                        print(selectedMonth);

                      });
                    },
                    value: selectedMonth),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  "Seçili Ayın Ödemeleri",
                  style: Theme.of(context).textTheme.headline1,
                  textAlign: TextAlign.center,
                ),
                SingleChildScrollView(
                  child: Container(
                    width: size.width,
                    height: size.height * 0.2,
                    child: ListView(
                      children: [
                        for (var item in _values)
                          if (item['month'] == selectedMonth)
                            PaymentTableTappable(
                              name: item['name'],
                              daysLated: 3,
                              monthly: int.parse((item['monthly'] ?? "-6")),
                              status: item['status'] ?? "unpaid",
                            )
                      ],
                    ),
                  ),
                ),
              ],
            ))
        : const Center(child: CircularProgressIndicator(color: Colors.black));
  }

  Future<List<Map<String, String>>> getPaymentTable() async {
    String? name, month, monthly, price, status;
    
    var url = Uri.http(deployURL, 'parent/getChildrenPayments');
    final response = await http.post(url, headers: {
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'parentPhone': await getUserPhone(),
    });

     final parsed = jsonDecode(response.body);
    print("Parsed about to be parsed..........");
    print(parsed);
  
     print("Payment about to be parsed..........");
    //print(parsed['summary']);

    List<Map<String, String>> mockData = [
      {
        'name': 'Arda Çelik',
        'month': 'Ocak',
        'monthly': '700',
        'price': '2800',
        'status': 'unpaid'
      },
      {
        'name': 'Derin Karaoğlu',
        'month': 'Şubat',
        'monthly': '500',
        'price': '1500',
        'status': 'paid'
      },
    ];
    return mockData;
  }
}
