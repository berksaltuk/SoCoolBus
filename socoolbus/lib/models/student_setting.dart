class StudentSetting {
  final String schoolName;
  final String secondPhone;
  final int stuClass;
  final bool smsPreference;
  final bool notificationPreference;
  final bool callPreference;

  StudentSetting({
    required this.schoolName,
    required this.secondPhone,
    required this.stuClass,
    required this.smsPreference,
    required this.notificationPreference,
    required this.callPreference,
  });

  factory StudentSetting.fromJson(Map<String, dynamic> json) {
    return StudentSetting(
        schoolName: json["schoolName"],
        secondPhone: json["secondPhone"],
        stuClass: json["class"],
        smsPreference: json["smsPreference"],
        notificationPreference: json["notificationPreference"],
        callPreference: json["callPreference"]);
  }
}
