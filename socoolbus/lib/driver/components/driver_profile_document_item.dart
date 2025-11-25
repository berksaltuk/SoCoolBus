import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/components/pdf_view.dart';
import 'package:my_app/constants.dart';
import 'package:http/http.dart' as http;

class DriverProfileDocumentItem extends StatelessWidget {
  final int installmentTotal = 9;

  const DriverProfileDocumentItem(
      {super.key,
      required this.documentId,
      required this.title,
      required this.validUntil,
      required this.uploadDate,
      required this.note,
      required this.validStatus});

  final String documentId;
  final String title;
  final DateTime? validUntil;
  final DateTime uploadDate;
  final String note;
  final bool validStatus;

  @override
  Widget build(BuildContext context) {
    //String dateStr = DateFormat.yMMMd().format(DateTime.now());
    String uploadDateFormat = DateFormat('d/MM/yyyy').format(uploadDate);
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
                    validUntil != null
                        ? Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              'Geçerlilik Tarihi: ${DateFormat('d/MM/yyyy').format(validUntil!)}',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          )
                        : const SizedBox(),
                    const SizedBox(
                      height: 5,
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Onay Durumu: ${validStatus ? "Onaylandı" : "Onaylanmadı"}',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Row(children: [
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye),
                      color: COLOR_DARK_GREY,
                      onPressed: () async {
                        retriveFile(documentId).then((value) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PDFViewerScreen(
                                  pdfData: (value),
                                ),
                              ));
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.info),
                      color: COLOR_DARK_GREY,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              elevation: 16,
                              child: ListView(
                                shrinkWrap: true,
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 20),
                                    child: Column(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Bilgi',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline3,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Yükleme Tarihi: $uploadDateFormat",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline2,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            note,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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

  Future<Uint8List> retriveFile(String documentId) async {
    var url = Uri.http(deployURL, 'driver/retrieveFile');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'id': documentId,
    });
    print(response.body);
    return response.bodyBytes;
  }
}
