import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/driver/settings/driver_add_iban.dart';
import 'package:my_app/my_enum.dart';
import 'package:http/http.dart' as http;
import '../../components/common_methods.dart';
import 'finance_button.dart';
import 'package:share_plus/share_plus.dart';

class SchoolBusListItem extends StatelessWidget {
  final int installmentTotal = 9;

  const SchoolBusListItem({
    super.key,
    required this.driverName,
    required this.plate,
    required this.phone,
    required this.city,
    required this.region,
    required this.route,
  });

  final String driverName;
  final String plate;
  final String phone;
  final String city;
  final String region;
  final String route;

  Widget build(BuildContext context) {
    //String dateStr = DateFormat.yMMMd().format(DateTime.now());
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6), color: COLOR_WHITE),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        driverName,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        plate,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        phone,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      city,
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      region,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      route,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Future<void> deleteIBAN(String accountId) async {
    var url = Uri.http(deployURL, 'driver/deleteIBAN');
    print(url);
    final response = await http.delete(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'accountId': accountId
    });
    print(response.body);
  }
}
