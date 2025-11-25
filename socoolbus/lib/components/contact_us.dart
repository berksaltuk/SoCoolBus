import 'package:flutter/material.dart';
import 'package:my_app/components/general_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Uri web = Uri.https("www.servisyolum.com");

    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          // ignore: prefer_const_constructors
          title: Text(
            'Bize Ulaşın/İletişim',
            style: const TextStyle(fontSize: 24),
          ),
        ),
        body: Padding(
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
                        margin: EdgeInsets.only(bottom: 10),
                        height: size.height * 0.61,
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            Container(
                              width: size.width,
                              margin: EdgeInsets.only(bottom: 10),
                              height: size.height * 0.0752,
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text("Firma"),
                                      SizedBox(
                                        width: size.width * 0.1,
                                      ),
                                      Text("Gold Turizm Ltd. Şti.")
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: size.width,
                              margin: EdgeInsets.only(bottom: 10),
                              height: size.height * 0.0752,
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text("Marka"),
                                      SizedBox(
                                        width: size.width * 0.1,
                                      ),
                                      Text("Servis Yolum Ltd. Şti.")
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: size.width,
                              margin: EdgeInsets.only(bottom: 10),
                              height: size.height * 0.0752,
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text("E-mail"),
                                      SizedBox(
                                        width: size.width * 0.1,
                                      ),
                                      TextButton(
                                        child: const Text(
                                          "info@servisyolum.com",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        onPressed: () async {
                                          await launchUrlString("mailto:info@servisyolum.com");
                                        },
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: size.width,
                              margin: EdgeInsets.only(bottom: 10),
                              height: size.height * 0.0752,
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text("İrtibat"),
                                      SizedBox(
                                        width: size.width * 0.1,
                                      ),
                                      TextButton(
                                        child: const Text(
                                          "532 060 2822",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        onPressed: () async {
                                          await launchUrlString(
                                              "tel:+905320602822");
                                        },
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: size.width,
                              margin: EdgeInsets.only(bottom: 10),
                              height: size.height * 0.0752,
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text("Adres"),
                                      SizedBox(
                                        width: size.width * 0.1,
                                      ),
                                      Text("Gaziantep / Şehitkamil")
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: size.width,
                              margin: EdgeInsets.only(bottom: 10),
                              height: size.height * 0.0752,
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text("Web"),
                                      SizedBox(
                                        width: size.width * 0.1,
                                      ),
                                      TextButton(
                                        child: const Text(
                                          "www.servisyolum.com",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        onPressed: () async {
                                          await launchUrl(web);
                                        },
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            GeneralButton(
                                onPressed: (() {}),
                                child: Text("Müşteri Hizmetleri"))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
