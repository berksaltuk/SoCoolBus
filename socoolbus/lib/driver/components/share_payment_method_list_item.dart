import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_app/auth/forgot.dart';
import 'package:my_app/components/select_general.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/driver/components/select_account.dart';
import 'package:my_app/driver/settings/driver_add_iban.dart';
import 'package:my_app/driver/sub_finance/share_payment_method_page.dart';
import 'package:my_app/models/account.dart';
import 'package:my_app/models/student.dart';
import 'package:my_app/my_enum.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../components/common_methods.dart';
import 'package:share_plus/share_plus.dart';

class SharePaymentItem extends StatefulWidget {
  const SharePaymentItem({
    super.key,
    required this.student,
  });

  final Student student;
  @override
  State<SharePaymentItem> createState() => SharePaymentItemState();
}

class SharePaymentItemState extends State<SharePaymentItem> {
  final int installmentTotal = 9;
  Account? selectedAccount;
  String? selectedMethod;
  late List<Account> accounts;

  @override
  initState() {
    getAccountsByDriver().then((value) => accounts = value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                child: Row(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.student.name,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(builder: (context, setState) {
                            return AlertDialog(
                              title: const Text("Paylaş"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text("Mesaj Yollanacak Hesap"),
                                  DropdownAccount(
                                      list: accounts,
                                      onChanged: (p0) {
                                        selectedAccount = p0;
                                        setState(() {});
                                      },
                                      selectedValue: selectedAccount),
                                  const Text("Mesaj Gönderme Methodu"),
                                  DropdownGeneral(
                                      list: const ["SMS", "WhatsApp"],
                                      onChanged: (p0) {
                                        selectedMethod = p0;
                                        setState(() {});
                                      },
                                      selectedValue: selectedMethod,
                                      searchable: false)
                                ],
                              ),
                              actions: [
                                TextButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              COLOR_ORANGE)),
                                  onPressed: () async {
                                    if (selectedAccount == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Lütfen hesap seçin!'),
                                        ),
                                      );
                                    } else if (selectedMethod == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Lütfen method seçin!'),
                                        ),
                                      );
                                    } else {
                                      if (selectedMethod == "WhatsApp") {
                                        await sendWPMessage(
                                            selectedAccount!, widget.student);
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Ödeme bilgisi veliye WhatsApp üzerinden iletildi.'),
                                          ),
                                        );
                                      } else {
                                        sendPaymentMethodSMS(
                                            selectedAccount, widget.student);
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Ödeme bilgisi veliye SMS olarak iletildi.'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text("Gönder"),
                                )
                              ],
                            );
                          });
                        });
                  },
                  icon: const Icon(Icons.share),
                  color: COLOR_DARK_GREY,
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  void sendPaymentMethodSMS(Account? selectedAccount, Student student) async {
    var url = Uri.http(deployURL, 'sms/shareIBAN');
    if (selectedAccount == null) {
      return;
    }
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      "student_id": student.studentId,
      "account_id": selectedAccount.accountId
    });
    print(response.body);
  }

  Future<bool> sendWPMessage(Account acc, Student stu) async {
    print(stu.secondPhone);
    var phone = stu.secondPhone;
    String receiver = acc.receiver;
    String msg = "Servis ödemenizi alıcısı $receiver";
    String iban = acc.iban;
    msg += " olan ${acc.bankName} $iban adresine yapmanız önemle rica olunur.";

    Uri myUri = Uri.parse("https://wa.me/90$phone?text=$msg");
    return await canLaunchUrl(myUri) ? await launchUrl(myUri) : false;
    //_launchURL(myUri);
  }
/* void _launchURL(Uri link) async => await canLaunchUrl(link)
      ? await launchUrl(link)
      : throw 'Could not launch $link'; */
}
