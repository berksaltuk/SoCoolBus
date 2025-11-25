import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/constants.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/driver/settings/subscription_subpages/old_subscription_details.dart';
import 'package:my_app/models/subscription.dart';

class OldSubscriptionPage extends StatefulWidget {
  const OldSubscriptionPage({super.key});

  @override
  State<OldSubscriptionPage> createState() => _OldSubscriptionPageState();
}

class _OldSubscriptionPageState extends State<OldSubscriptionPage> {

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Geçmiş Üyelikler"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            //select school
            const SizedBox(height: 10),
            // expenses
            SingleChildScrollView(
              child: Container(
                width: size.width,
                margin: const EdgeInsets.only(bottom: 10),
                height: size.height * 0.70,
                child: FutureBuilder<List<Subscription>>(
                  future: getOldSubscriptions(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                            'Bir hata oluştu!\n${snapshot.error!.toString()}'),
                      );
                    } else if (snapshot.hasData) {
                      if (snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('Eski üyelik yok!'),
                        );
                      }
                      return ListView(
                        children: [
                          for (var subscription in snapshot.data!)
                            SubscriptionDetails(
                              subscriptionId: subscription.subscriptionId,
                              startDate: subscription.startDate,
                              endDate: subscription.endDate,
                              maxSchoolNumber: subscription.maxSchoolNumber,
                              fee: subscription.fee,
                              type: subscription.type,
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

  Future<List<Subscription>> getOldSubscriptions() async {
    var url = Uri.http(deployURL, 'driver/getSubscriptionHistory');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'driverPhone': await getUserPhone()
    });
    print(response.body);

    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    return parsed
        .map<Subscription>((json) => Subscription.fromJson(json))
        .toList();
  }
}
