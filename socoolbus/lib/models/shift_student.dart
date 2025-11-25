import 'package:flutter/material.dart';
import 'package:my_app/my_enum.dart';

class ShiftStudent {
  ShiftStudent({
    required this.expandedValue,
    required this.studentID,
    required this.name,
    required this.paymentStatus,
    required this.callButton,
    required this.status,
    this.isStatusChanged = false,
    this.isExpanded = false,
    this.thumbColor = Colors.black,
  });
  final String studentID;
  final String name;
  String expandedValue;
  String paymentStatus;
  final bool callButton;
  bool isStatusChanged;
  bool isExpanded;
  DateTime? statusUpdateTime;
  ShiftStudentStatus status;
  Color thumbColor;

  factory ShiftStudent.fromJson(Map<String, dynamic> json) {
    ShiftStudentStatus status =
        stringToShiftStatus[json["attendanceDescription"]] ??
            ShiftStudentStatus.waiting;
    Color thumbColor = statusToColor[status] ?? Colors.blue;
    return ShiftStudent(
      thumbColor: thumbColor,
      studentID: json["studentID"],
      name: json["studentName"],
      paymentStatus: json["paymentStatus"],
      callButton: json["callButton"],
      expandedValue: "exp val",
      status: status,
    );
  }

  void changeStatus(ShiftStudentStatus status) {
    switch (status) {
      case ShiftStudentStatus.takenNormal:
        this.status = ShiftStudentStatus.takenNormal;
        thumbColor = Colors.green;
        break;
      case ShiftStudentStatus.takenWaited:
        this.status = ShiftStudentStatus.takenWaited;
        thumbColor = Colors.orange;
        break;
      case ShiftStudentStatus.driverPermittied:
        this.status = ShiftStudentStatus.driverPermittied;
        thumbColor = Colors.yellow;
        break;
      case ShiftStudentStatus.notTakenWaited:
        this.status = ShiftStudentStatus.notTakenWaited;
        thumbColor = Colors.red;
        break;
      //S2H Statuses
      case ShiftStudentStatus.inTheVehicle:
        this.status = ShiftStudentStatus.inTheVehicle;
        thumbColor = Colors.green;
        break;
      case ShiftStudentStatus.notInTheVehicle:
        this.status = ShiftStudentStatus.notInTheVehicle;
        thumbColor = Colors.red;
        break;
      case ShiftStudentStatus.dropedHome:
        this.status = ShiftStudentStatus.dropedHome;
        thumbColor = Colors.green;
        break;
      case ShiftStudentStatus.dropedLocation:
        this.status = ShiftStudentStatus.dropedLocation;
        thumbColor = Colors.green;
        break;
      default:
        this.status = ShiftStudentStatus.waiting;
        thumbColor = Colors.blue;
    }
  }
}
/*
List<ShiftStudent> generateItems(int numberOfItems) {
  return List<ShiftStudent>.generate(numberOfItems, (int index) {
    return ShiftStudent(
      headerValue: ShiftListItem(
        thumbnail: Container(
          decoration: const BoxDecoration(color: Colors.green),
        ),
        title: "Okula Bırakıldı",
        user: "Arda Çelik",
        dateof: DateTime.now().toUtc(),
        payment: "•Ödeme: Gecikti",
        notification: NotificationButton(),
      ),
      expandedValue: "exp val",
      status: ShiftStudentStatus.waiting
    );
  });
}*/