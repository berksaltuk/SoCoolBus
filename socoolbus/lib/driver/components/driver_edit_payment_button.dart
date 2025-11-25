import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/components/general_button.dart';
import 'package:my_app/components/select_general.dart';
import 'package:my_app/constants.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/driver/sub_finance/driver_enter_postpone_payment_screen.dart';

class EditPaymentButton extends StatefulWidget {
  final String paymentId;
  final int leftAmount;

  const EditPaymentButton(
      {required this.paymentId, required this.leftAmount, super.key});

  @override
  State<EditPaymentButton> createState() => _EditPaymentButtonState();
}

class _EditPaymentButtonState extends State<EditPaymentButton> {
  static const IconData notifications =
      IconData(0xe44f, fontFamily: 'MaterialIcons');

  bool pressed = false;
  String? selectedPostponeAmount;
  TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 20,
      child: TextButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: pressed ? Colors.green : Colors.orange,
        ),
        onPressed: () {
          setState(() {
            openDialog();
          });
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  Future<void> updatePayment(String paymentId, String text) async {
    var url = Uri.http(deployURL, 'driver/updatePayment');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'id': paymentId,
      'paid': text
    });
    print(response.body);
  }

  Future<void> postponePayment(String paymentId, String? postponeAmount) async {
    if (postponeAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen erteleme miktarını girin!'),
        ),
      );
    }

    var url = Uri.http(deployURL, 'driver/postponePayment');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'id': paymentId,
      'postponeAmount': postponeAmount
    });
    print(response.body);
  }

  openDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                title: const Text("Not Ekle"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GeneralButton(
                        onPressed: () {
                          openEnterPaymentDialog();
                          setState(() {});
                        },
                        child: const Text("Tahsilat Gir")),
                    GeneralButton(
                        onPressed: () {
                          openPostponePaymentDialog();
                          setState(() {});
                        },
                        child: const Text("Tahsilat Ertele")),
                  ],
                ));
          });
        });
  }

  openEnterPaymentDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text("Tahsilat Gir"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Kalan Ödeme Miktarı: ${widget.leftAmount}"),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: amountController,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 2, color: COLOR_DARK_GREY),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 2, color: COLOR_LIGHT_GREY),
                      ),
                      hintText: 'Miktar',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(COLOR_ORANGE)),
                  onPressed: () async {
                    if (widget.leftAmount < int.parse(amountController.text)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Girilen miktar kalan tutardan fazla olamaz!'),
                        ),
                      );
                    } else {
                      await updatePayment(widget.paymentId, amountController.text);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EnterPostponePayment()),
                        );
                        
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tahsilat başarıyla eklendi.'),
                        ),
                      );
                    }
                    setState(
                      () {},
                    );
                  },
                  child: const Text("Ekle"),
                )
              ],
            );
          });
        });
  }

  openPostponePaymentDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text("Tahsilat Ertele"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Kalan Ödeme Miktarı: ${widget.leftAmount}"),
                  DropdownGeneral(
                      list: const ["1", "2", "3"],
                      onChanged: (p0) {
                        selectedPostponeAmount = p0;
                        setState(() {
                          
                        });
                      },
                      selectedValue: selectedPostponeAmount,
                      searchable: false)
                ],
              ),
              actions: [
                TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(COLOR_ORANGE)),
                  onPressed: () async {
                    if (selectedPostponeAmount == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lütfen erteleme miktarını girin!'),
                        ),
                      );
                    } else {
                      await postponePayment(widget.paymentId, selectedPostponeAmount);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EnterPostponePayment()),
                        );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tahsilat başarıyla ertelendi.'),
                        ),
                      );
                    }
                  },
                  child: const Text("Ertele"),
                )
              ],
            );
          });
        });
  }
}
