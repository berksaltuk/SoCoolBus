import 'dart:convert';
import 'dart:io';

import 'package:my_app/models/account.dart';
import 'package:my_app/models/student.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/school.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'package:logger/logger.dart';

var logger = Logger();

Future<String> getUserName() async {
  final SharedPreferences session = await SharedPreferences.getInstance();
  final String? name = session.getString('name');
  Future<String> future = Future.value(name);
  return future;
}

Future<String> getUserPhone() async {
  final SharedPreferences session = await SharedPreferences.getInstance();
  final String? phone = session.getString('phone');
  Future<String> future = Future.value(phone);
  return future;
}

Future<String> getUserToken() async {
  final SharedPreferences session = await SharedPreferences.getInstance();
  final String? token = session.getString('token');
  Future<String> future = Future.value("Bearer $token");
  return future;
}

Future<List<String>> getUserTypes() async {
  final SharedPreferences session = await SharedPreferences.getInstance();
  final List<String>? userTypes = session.getStringList('canHaveRoles');
  Future<List<String>> future = Future.value(userTypes);
  return future;
}

void setSelectedSchool(String schoolID) async {
  final SharedPreferences session = await SharedPreferences.getInstance();
  session.setString('school', schoolID);
}

Future<String?> getSelectedSchool() async {
  final SharedPreferences session = await SharedPreferences.getInstance();
  final String? schoolID = session.getString('school');
  Future<String?> future = Future.value(schoolID);
  return future;
}

/* Future<List<School>> getAllSchools() async {
  var url = Uri.http(deployURL, 'school/getAllSchools');

  final response = await http.get(url, headers: {
    HttpHeaders.authorizationHeader: await getUserToken(),
    "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
  });

  final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
  return parsed.map<School>((json) => School.fromJson(json)).toList();
} */

Future<List<School>> getAllSchools() async {
  var url = Uri.http(deployURL, 'school/getAllSchools');

  final response = await http.get(url, headers: {
    "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
  });

  final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
  return parsed.map<School>((json) => School.fromJson(json)).toList();
}

Future<List<School>> getDriverSchools(Future<String> phone) async {
  var url = Uri.http(deployURL, 'school/getDriverSchools');
  String stringPhone = await phone;
  final response = await http.post(url, headers: {
    HttpHeaders.authorizationHeader: await getUserToken(),
    "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
  }, body: {
    'phone': stringPhone
  });

  final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
  return parsed.map<School>((json) => School.fromJson(json)).toList();
}

Future<List<Student>> getParentChildren(Future<String> phone) async {
  var url = Uri.http(deployURL, 'parent/getChildren');
  String stringPhone = await phone;
  final response = await http.post(url, headers: {
    HttpHeaders.authorizationHeader: await getUserToken(),
    "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
  }, body: {
    'phone': stringPhone
  });

  final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
  return parsed.map<Student>((json) => Student.fromJson(json)).toList();
}

Future<List<Student>> getSchoolStudents(School? school) async {
  var url = Uri.http(deployURL, 'school/getSchoolStudents');
  if (school == null) {
    return [];
  }
  logger.i(url);
  final response = await http.post(url, headers: {
    HttpHeaders.authorizationHeader: await getUserToken(),
    "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
  }, body: {
    'schoolId': school.schoolId
  });
  logger.i(response.body);

  final parsed = jsonDecode(response.body).cast<Map<dynamic, dynamic>>();
  return parsed.map<Student>((json) => Student.fromJson(json)).toList();
}

Future<List<Student>> getDriverSchoolStudents(School? school) async {
  var url =
      Uri.http(deployURL, 'school/getSchoolStudentsByDriverWithoutDirection');
  if (school == null) {
    return [];
  }
  logger.i(url);
  final response = await http.post(url, headers: {
    HttpHeaders.authorizationHeader: await getUserToken(),
    "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
  }, body: {
    'schoolID': school.schoolId,
    'driverPhone': await getUserPhone(),
  });
  logger.i(response.body);

  final parsed = jsonDecode(response.body).cast<Map<dynamic, dynamic>>();
  return parsed.map<Student>((json) => Student.fromJson(json)).toList();
}

Future<List<Student>> getDriverSchoolStudentsWithCurrentSchool() async {
  var url =
      Uri.http(deployURL, 'school/getSchoolStudentsByDriverWithoutDirection');
  logger.i(url);
  final response = await http.post(url, headers: {
    HttpHeaders.authorizationHeader: await getUserToken(),
    "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
  }, body: {
    'schoolID': await getSelectedSchool(),
    'driverPhone': await getUserPhone(),
  });
  logger.i(response.body);

  final parsed = jsonDecode(response.body).cast<Map<dynamic, dynamic>>();
  return parsed.map<Student>((json) => Student.fromJson(json)).toList();
}

void switchUserType(String roleTR) async {
  var url = Uri.http(deployURL, 'user/switchUserType');
  var role;
  logger.i(url);
  if (roleTR == "Veli") {
    role = "PARENT";
  } else if (roleTR == "Sürücü") {
    role = "DRIVER";
  }

  final response = await http.post(url, headers: {
    HttpHeaders.authorizationHeader: await getUserToken(),
    "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
  }, body: {
    'phone': await getUserPhone(),
    'role': role,
  });
  logger.i(response.body);
  final token = jsonDecode(response.body)['token'];
  final SharedPreferences session = await SharedPreferences.getInstance();
  await session.setString('token', token);
}

String getCurrentMonthString() {
  Map<int, String> intToMonth = {
    1: 'Ocak',
    2: 'Şubat',
    3: 'Mart',
    4: 'Nisan',
    5: 'Mayıs',
    6: 'Haziran',
    7: 'Temmuz',
    8: 'Ağustos',
    9: 'Eylül',
    10: 'Ekim',
    11: 'Kasım',
    12: 'Aralık',
  };
  return intToMonth[DateTime.now().month] ?? "Ocak";
}

Future<School?> findSchoolById(String id) async {
  var url = Uri.http(deployURL, 'school/findSchoolById');
  logger.i(url);
  final response = await http.post(url, headers: {
    HttpHeaders.authorizationHeader: await getUserToken(),
    "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
  }, body: {
    'id': id
  });
  logger.i(response.body);
  if (response.body == null) {
    print("hehe");
    return null;
  }

  return School.fromJson(jsonDecode(response.body));
}

Future<List<Account>> getAccountsByDriver() async {
  var url = Uri.http(deployURL, 'driver/getAccountsByDriver');
  print(url);
  final response = await http.post(url, headers: {
    HttpHeaders.authorizationHeader: await getUserToken(),
    "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
  }, body: {
    'phone': await getUserPhone()
  });
  print(response.body);

  final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
  return parsed.map<Account>((json) => Account.fromJson(json)).toList();
}
