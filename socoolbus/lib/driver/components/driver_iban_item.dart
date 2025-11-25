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

class IBANitem extends StatelessWidget {
  final int installmentTotal = 9;

  const IBANitem({
    super.key,
    required this.accountId,
    required this.title,
    required this.bank,
    required this.holder,
    required this.iban,
  });

  final String accountId;
  final String title;
  final String bank;
  final String holder;
  final String iban;

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
                        title,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        bank,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        holder,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        iban,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    IconButton(
                      onPressed: () async {
                        await Share.share(iban);
                      },
                      icon: const Icon(Icons.share),
                      color: COLOR_DARK_GREY,
                    ),
                    /* IconButton(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: iban));
                          final snackBar = SnackBar(
                            content: const Text('IBAN Kopyalandı.'),
                            action: SnackBarAction(
                              label: '',
                              onPressed: () {
                                // Some code to undo the change.
                              },
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        icon: const Icon(Icons.copy)), */
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: COLOR_DARK_GREY,
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              elevation: 16,
                              child: Container(
                                child: ListView(
                                  shrinkWrap: true,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Hesap bilgisini silmek istediğinize emin misiniz?',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Hayır')),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Expanded(
                                                child: ElevatedButton(
                                                    onPressed: () async {
                                                      await deleteIBAN(
                                                          this.accountId);
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Evet')),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ]),
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
