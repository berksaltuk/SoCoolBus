import 'package:my_app/my_enum.dart';

class Payment {
  final String paymentId;
  final int totalAmount;
  final String paidBy;
  final PaymentStatus status;
  final String paymentNumber;
  final int paidAmount;
  final int leftAmount;

  const Payment(
      {required this.paymentId,
      required this.totalAmount,
      required this.paidBy,
      required this.status,
      required this.paymentNumber,
      required this.paidAmount,
      required this.leftAmount});

  factory Payment.fromJson(Map<dynamic, dynamic> json) {
    PaymentStatus temp;
    if(json['paymentStatus'] == 'paid'){
        temp = PaymentStatus.paid;
    }
    else if(json['paymentStatus'] == 'unpaid'){
        temp = PaymentStatus.unpaid;
    }else if(json['paymentStatus'] == 'postponed'){
        temp = PaymentStatus.postponed;
    } else if(json['paymentStatus'] == 'late'){
        temp = PaymentStatus.late;
    }else {
        temp = PaymentStatus.requested;
    }
    return Payment(
      paymentId: json['_id'],
      totalAmount: (json['leftAmount'] + json['paidAmount']).toInt(),
      leftAmount: json['leftAmount'].toInt(),
      paidBy: json['paidBy'],
      status: temp,
      paymentNumber: json['paymentNumber'],
      paidAmount: json['paidAmount'].toInt(),
    );
  }
}
