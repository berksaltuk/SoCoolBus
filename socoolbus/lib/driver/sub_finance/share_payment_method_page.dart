import 'package:flutter/material.dart';
import 'package:my_app/models/student.dart';

import '../../components/common_methods.dart';
import '../../models/school.dart';
import '../components/share_payment_method_list_item.dart';

class SharePaymentMethodPage extends StatefulWidget {
  @override
  State<SharePaymentMethodPage> createState() =>
      _SharePaymentMethodPageScreenState();
  const SharePaymentMethodPage({super.key});
}

@override
class _SharePaymentMethodPageScreenState extends State<SharePaymentMethodPage> {
  School? selectedSchool;

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Ödeme Yöntemi Paylaş"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      FutureBuilder<List<Student>>(
                        future: getDriverSchoolStudentsWithCurrentSchool(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text("Bağlantıyı kontrol ediniz.");
                          } else if (snapshot.hasData) {
                            if (snapshot.data!.isEmpty) {
                              return Column(
                                children: const [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Center(
                                      child: Text(
                                    "Bu okulda öğrenci bulunamadı..",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ))
                                ],
                              );
                            }
                            return Column(
                              children: [
                                for (var student in snapshot.data!)
                                  SharePaymentItem(
                                    student: student,
                                  ),
                              ],
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            );
                          }
                        },
                      ),
                    ]))));
  }
}
