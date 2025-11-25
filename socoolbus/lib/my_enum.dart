import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

enum FinanceStatus { income, expense, requested, postponed }

enum PaymentStatus { paid, unpaid, late, postponed, requested }

extension ParseToString on PaymentStatus {
  String getEnum() {
    String temp = this.toString().split('.').last;
    if (temp == "paid") {
      return "Ödendi";
    } else if (temp == "unpaid") {
      return "Ödenmedi";
    } else if (temp == "postponed") {
      return "Ertelendi";
    } else if (temp == "requested") {
      return "İstendi";
    } else if (temp == "late") {
      return "Gecikti";
    } else {
      return "";
    }
  }
}

enum DocumentType { license, registration, psychotechnic }

extension ParseToStringDocument on DocumentType {
  String getEnum() {
    String temp = this.toString().split('.').last;
    if (temp == "license") {
      return "Ehliyet";
    } else if (temp == "registration") {
      return "Ruhsat";
    } else if (temp == "psychotechnic") {
      return "Psikoteknik";
    } else {
      return "";
    }
  }
}

enum ShiftStudentStatus {
  waiting,
  permission,
  takenNormal,
  takenWaited,
  notTakenWaited,
  driverPermittied,
  inTheVehicle,
  notInTheVehicle,
  dropedHome,
  dropedLocation,
}

extension ParseToStringStuStatus on ShiftStudentStatus {
  String getEnum() {
    String temp = this.toString().split('.').last;
    if (temp == "waiting") {
      return "Beklemede";
    } else if (temp == "permission") {
      return "İzinli";
    } else if (temp == "takenNormal") {
      return "Zamanında Alındı";
    } else if (temp == "takenWaited") {
      return "Beklendi Alındı";
    } else if (temp == "notTakenWaited") {
      return "Beklendi Alınmadı";
    } else if (temp == "driverPermittied") {
      return "İzinli";
    } else if (temp == "inTheVehicle") {
      return "Servise Bindi";
    } else if (temp == "notInTheVehicle") {
      return "Servise Binmedi";
    } else if (temp == "dropedHome") {
      return "Eve Bırakıldı";
    } else if (temp == "dropedLocation") {
      return "Konuma Bırakıldı";
    } else {
      return "";
    }
  }
}

Map<String, ShiftStudentStatus> stringToShiftStatus = {
  "İzinli": ShiftStudentStatus.permission,
  "Beklemede": ShiftStudentStatus.waiting,
  "Zamanında Alındı": ShiftStudentStatus.takenNormal,
  "Beklendi Alındı": ShiftStudentStatus.takenWaited,
  "Servise Bindi": ShiftStudentStatus.inTheVehicle,
  "Servise Binmedi": ShiftStudentStatus.notInTheVehicle,
  "Eve Bırakıldı": ShiftStudentStatus.dropedHome,
  "Konuma Bırakıldı": ShiftStudentStatus.dropedLocation,
};

Map<ShiftStudentStatus, MaterialColor> statusToColor = {
  ShiftStudentStatus.permission: Colors.yellow,
  ShiftStudentStatus.waiting: Colors.blue,
  ShiftStudentStatus.takenNormal: Colors.green,
  ShiftStudentStatus.takenWaited: Colors.orange,
  ShiftStudentStatus.inTheVehicle: Colors.green,
  ShiftStudentStatus.notInTheVehicle: Colors.red,
  ShiftStudentStatus.dropedHome: Colors.green,
  ShiftStudentStatus.dropedLocation: Colors.green,
  ShiftStudentStatus.driverPermittied: Colors.yellow,
  ShiftStudentStatus.notTakenWaited: Colors.red,
};

Map<String, String> typeToString = {
  "PAID": "Ücretli",
  "TRIAL": "Deneme",
};

enum PaymentWho { parent, organization, school }

extension ParsePaymentWho on PaymentWho {
  String getString() {
    if (this == PaymentWho.organization) {
      return "Kurum";
    } else if (this == PaymentWho.school) {
      return "Okul";
    } else {
      return "Veli/Öğrenci";
    }
  }

  PaymentWho fromString(String s) {
    if (s == "Kurum") {
      return PaymentWho.organization;
    } else if (s == "Okul") {
      return PaymentWho.school;
    } else {
      return PaymentWho.parent;
    }
  }

  int getInt() {
    if (this == PaymentWho.organization) {
      return 1;
    } else if (this == PaymentWho.school) {
      return 2;
    } else {
      return 0;
    }
  }

  PaymentWho fromInt(int i) {
    if (i == 1) {
      return PaymentWho.organization;
    } else if (i == 2) {
      return PaymentWho.school;
    } else {
      return PaymentWho.parent;
    }
  }
}

enum PaymentPreference { montly, yearly }

extension ParsePaymentPreference on PaymentPreference {
  String getString() {
    if (this == PaymentPreference.montly) {
      return "Aylık";
    } else {
      return "Yıllık";
    }
  }

  PaymentPreference fromString(String s) {
    if (s == "Aylık") {
      return PaymentPreference.montly;
    } else {
      return PaymentPreference.yearly;
    }
  }
  int getInt() {
    if (this == PaymentPreference.montly) {
      return 0;
    } else {
      return 1;
    }
  }

  PaymentPreference fromInt(int i) {
    if (i == 1) {
      return PaymentPreference.yearly;
    } else {
      return PaymentPreference.montly;
    }
  }
}
