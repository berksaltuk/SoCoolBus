import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/driver/components/driver_notification_button.dart';
import 'package:my_app/driver/components/expansion_panel_modified.dart';
import 'package:my_app/driver/components/finance_button.dart';
import 'package:my_app/driver/components/shift_list_item.dart';
import 'package:my_app/driver/components/shift_list_item_exp.dart';
import 'package:my_app/driver/components/shift_list_item_exp_s2h.dart';
import 'package:my_app/models/shift_student.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/my_enum.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class DriverStartShift extends StatefulWidget {
  final Future<String> shiftID;
  final String schoolName;
  const DriverStartShift(
      {required this.shiftID, required this.schoolName, super.key});

  @override
  State<DriverStartShift> createState() => _DriverStartShiftState();
}

class _DriverStartShiftState extends State<DriverStartShift> {
  late bool _isActive;

  late final List<ShiftStudent> _stuList;
  bool _isLoaded = false;
  bool _isH2S = true;
  int _pickedStudentCount = 0;
  int _waitingStudentCount = 0;
  bool _everyoneOnBoard = false;

  String leftSchool = "Servis başlatılmadı";
  bool onTheRoadFromSchool = false;
  String s2hCompletedTime = "Servis henüz bitmedi";
  bool s2hCompleted = false;

  String pickedUpFirst = "İlk öğrenci henüz alınmadı";
  bool onTheRoadToSchool = false;
  String pickedUpLast = "Son öğrenci alınmadı";
  String h2sCompletedTime = "Servis henüz bitirilmedi";
  bool h2sCompleted = false;

  var _timer;

  @override
  void initState() {
    getShift(widget.shiftID).then((value1) {
      getShiftType(widget.shiftID).then((value) {
        _isH2S = value;
        setState(() {
          _stuList = value1;
          _isLoaded = true;
          _waitingStudentCount = _stuList.length;
        });
        if (_isActive) {
          _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
            sendLocation(widget.shiftID);
          });
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
// To cancel the timer after 1 minute:

    FocusScope.of(context).requestFocus(FocusNode());
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Servise Başla"),
          ),
          body: Center(
              child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    widget.schoolName,
                    style: const TextStyle(
                      fontSize: 18,
                      color: COLOR_BLACK,
                    ),
                  ),
                ),
              ),
              _isLoaded
                  ? SingleChildScrollView(
                      child: _isH2S
                          ? _buildPanelH2S(_stuList)
                          : !_everyoneOnBoard
                              ? _buildPanelS2H(_stuList)
                              : _buildPanelS2H(_stuList),
                    )
                  : const CircularProgressIndicator(
                      color: Colors.black,
                    ),
            ],
          )),
        ),
        onWillPop: () async {
          Timer(const Duration(seconds: 1), () => _timer.cancel());
          return true;
        });
  }

  Widget _buildPanelH2S(List<ShiftStudent> stuList) {
    TimeOfDay time = TimeOfDay.fromDateTime(DateTime.now());
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Öğrenci Evden Alınma Oranı",
              style: TextStyle(
                fontSize: 16,
                color: COLOR_BLACK,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: LinearPercentIndicator(
            lineHeight: 15,
            percent: _pickedStudentCount / _waitingStudentCount,
            progressColor: Colors.blue,
            backgroundColor: Colors.white70,
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Servise Başlama Saati: $pickedUpFirst",
              style: const TextStyle(
                fontSize: 16,
                color: COLOR_BLACK,
              ),
            ),
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Son Öğrenciyi Alma Saati: $pickedUpLast",
              style: const TextStyle(
                fontSize: 16,
                color: COLOR_BLACK,
              ),
            ),
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Okula Bırakma Saati: $h2sCompletedTime",
              style: const TextStyle(
                fontSize: 16,
                color: COLOR_BLACK,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Öğrenci Listesi",
              style: TextStyle(
                fontSize: 18,
                color: COLOR_BLACK,
              ),
            ),
          ),
        ),
        ExpansionPanelModifiedList(
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              _stuList.forEach((item) {
                item.isExpanded = false;
              });
              _stuList[index].isExpanded = !isExpanded;
            });
          },
          children: _stuList.map<ExpansionPanelModified>((ShiftStudent item) {
            return ExpansionPanelModified(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Container(
                  child: ShiftListItem(
                    thumbnail: Container(
                      decoration: BoxDecoration(color: item.thumbColor),
                    ),
                    title: item.status.getEnum(),
                    user: item.name,
                    dateof: DateTime.now().toUtc(),
                    payment: "•Ödeme: ${item.paymentStatus}",
                    notification: item.callButton
                        ? NotificationButton(
                            shiftID: widget.shiftID,
                            studentID: item.studentID,
                          )
                        : const SizedBox(),
                  ),
                );
              },
              body: ShiftListItemExp(
                buttonNotTakenAction: () {
                  setState(() {
                    if (!item.isStatusChanged) {
                      _pickedStudentCount++;
                      updateTimeH2S();
                      item.isStatusChanged = true;
                    }
                    item.isExpanded = false;

                    updateStudentStatus(
                        item.studentID, ShiftStudentStatus.notTakenWaited);
                    item.changeStatus(ShiftStudentStatus.notTakenWaited);
                  });
                },
                buttonPermittedAction: () {
                  setState(() {
                    if (!item.isStatusChanged) {
                      _pickedStudentCount++;
                      updateTimeH2S();
                      item.isStatusChanged = true;
                    }
                    item.isExpanded = false;
                    updateStudentStatus(
                        item.studentID, ShiftStudentStatus.driverPermittied);
                    item.changeStatus(ShiftStudentStatus.driverPermittied);
                  });
                },
                buttonTakenAction: () {
                  setState(() {
                    if (!item.isStatusChanged) {
                      _pickedStudentCount++;
                      updateTimeH2S();
                      item.isStatusChanged = true;
                    }
                    item.isExpanded = false;
                    updateStudentStatus(
                        item.studentID, ShiftStudentStatus.takenNormal);
                    item.changeStatus(ShiftStudentStatus.takenNormal);
                  });
                },
                buttonWaitedTakenAction: () {
                  setState(() {
                    if (!item.isStatusChanged) {
                      _pickedStudentCount++;
                      updateTimeH2S();
                      item.isStatusChanged = true;
                    }
                    item.isExpanded = false;
                    updateStudentStatus(
                        item.studentID, ShiftStudentStatus.takenWaited);
                    item.changeStatus(ShiftStudentStatus.takenWaited);
                  });
                },
              ),
              hasIcon: false,
              canTapOnHeader:
                  (item.status != ShiftStudentStatus.permission) && _isActive,
              isExpanded: item.isExpanded,
            );
          }).toList(),
        ),
        _isActive
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: IgnorePointer(
                  ignoring: h2sCompleted,
                  child: FinanceButton(
                    onPressed: () {
                      if (_pickedStudentCount / _waitingStudentCount == 1) {
                        endShift();
                        //Navigator.pop(context);
                        setState(() {
                          TimeOfDay time =
                              TimeOfDay.fromDateTime(DateTime.now());
                          h2sCompletedTime = time.format(context);
                          h2sCompleted = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sürüş bitirildi!')));
                      } else {
                        openError();
                      }
                    },
                    child: const Text(
                      "Okula Giriş Yap",
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  Widget _buildPanelS2H(List<ShiftStudent> stuList) {
    TimeOfDay time1 = TimeOfDay.fromDateTime(DateTime.now());
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Öğrenci Servise Binme Oranı",
              style: TextStyle(
                fontSize: 16,
                color: COLOR_BLACK,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: LinearPercentIndicator(
            lineHeight: 20,
            percent: _pickedStudentCount / _waitingStudentCount,
            progressColor: Colors.blue,
            backgroundColor: Colors.white70,
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Servise Başlama Saati: $leftSchool",
              style: const TextStyle(
                fontSize: 16,
                color: COLOR_BLACK,
              ),
            ),
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Servisi Bitirme Saati: $s2hCompletedTime",
              style: const TextStyle(
                fontSize: 16,
                color: COLOR_BLACK,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Öğrenci Listesi",
              style: TextStyle(
                fontSize: 18,
                color: COLOR_BLACK,
              ),
            ),
          ),
        ),
        ExpansionPanelModifiedList(
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              _stuList.forEach((item) {
                item.isExpanded = false;
              });
              _stuList[index].isExpanded = !isExpanded;
            });
          },
          children: _stuList.map<ExpansionPanelModified>((ShiftStudent item) {
            return ExpansionPanelModified(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Container(
                  child: ShiftListItem(
                    thumbnail: Container(
                      decoration: BoxDecoration(color: item.thumbColor),
                    ),
                    title: item.status.getEnum(),
                    user: item.name,
                    dateof: DateTime.now().toUtc(),
                    payment: "•Ödeme: ${item.paymentStatus}",
                    notification: item.callButton
                        ? NotificationButton(
                            studentID: item.studentID, shiftID: widget.shiftID)
                        : const SizedBox(),
                  ),
                );
              },
              body: !_everyoneOnBoard
                  ? ShiftListItemExpS2HNotStarted(
                      buttonInVehicleAction: () {
                        setState(() {
                          if (!item.isStatusChanged) {
                            _pickedStudentCount++;
                            item.isStatusChanged = true;
                          }
                          item.isExpanded = false;
                          updateStudentStatus(
                              item.studentID, ShiftStudentStatus.inTheVehicle);
                          item.changeStatus(ShiftStudentStatus.inTheVehicle);
                        });
                      },
                      buttonNotInVehicleAction: () {
                        setState(() {
                          if (!item.isStatusChanged) {
                            _pickedStudentCount++;
                            item.isStatusChanged = true;
                          }
                          item.isExpanded = false;
                          updateStudentStatus(item.studentID,
                              ShiftStudentStatus.notInTheVehicle);
                          item.changeStatus(ShiftStudentStatus.notInTheVehicle);
                        });
                      },
                    )
                  : ShiftListItemExpS2HStarted(
                      buttonDroppedHomeAction: () {
                        setState(() {
                          if (!item.isStatusChanged) {
                            _pickedStudentCount++;
                            item.isStatusChanged = true;
                          }
                          item.isExpanded = false;
                          updateStudentStatus(
                              item.studentID, ShiftStudentStatus.dropedHome);
                          item.changeStatus(ShiftStudentStatus.dropedHome);
                        });
                      },
                      buttonDroppedLocationAction: () {
                        setState(() {
                          if (!item.isStatusChanged) {
                            _pickedStudentCount++;
                            item.isStatusChanged = true;
                          }
                          item.isExpanded = false;
                          updateStudentStatus(item.studentID,
                              ShiftStudentStatus.dropedLocation);
                          item.changeStatus(ShiftStudentStatus.dropedLocation);
                        });
                      },
                    ),
              hasIcon: false,
              canTapOnHeader: !(item.status == ShiftStudentStatus.permission ||
                  (_everyoneOnBoard &&
                      (item.status == ShiftStudentStatus.notInTheVehicle)) ||
                  !_isActive),
              isExpanded: item.isExpanded,
            );
          }).toList(),
        ),
        const SizedBox(
          height: 10,
        ),
        _isActive
            ? !_everyoneOnBoard
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: FinanceButton(
                      onPressed: () {
                        if (_pickedStudentCount / _waitingStudentCount == 1) {
                          setState(() {
                            _everyoneOnBoard = true;
                            leftSchool = time1.format(context);
                            onTheRoadFromSchool = true;
                            for (var stu in stuList) {
                              stu.isStatusChanged = false;
                              if (stu.status ==
                                  ShiftStudentStatus.inTheVehicle) {
                                stu.changeStatus(ShiftStudentStatus.waiting);
                                _pickedStudentCount--;
                              }
                              stu.isExpanded = false;
                            }
                          });
                        } else {
                          openError();
                        }
                      },
                      child: const Text(
                        "Servisi Başlat",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: IgnorePointer(
                      ignoring: s2hCompleted,
                      child: FinanceButton(
                        onPressed: () {
                          if (_pickedStudentCount / _waitingStudentCount == 1) {
                            endShift();
                            setState(() {
                              for (var stu in stuList) {
                                stu.isExpanded = false;
                              }
                              onTheRoadFromSchool = false;
                              TimeOfDay time2 =
                                  TimeOfDay.fromDateTime(DateTime.now());
                              s2hCompletedTime = time2.format(context);
                              s2hCompleted = true;
                            });
                            //Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Sürüş bitirildi!')));
                          } else {
                            openError();
                          }
                        },
                        /* color: COLOR_DARK_GREY,
                    textColor: COLOR_WHITE,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    elevation: 5.0,
                    height: 40,
                    padding: const EdgeInsets.all(10), */
                        child: const Text(
                          "Servisi Bitir",
                        ),
                      ),
                    ),
                  )
            : const SizedBox(),
      ],
    );
  }

  String? makeItTime(String? plainDateTimeUTC) {
    try {
      DateTime dateTime = DateTime.parse(plainDateTimeUTC ?? "");
      DateTime turkeyTime = dateTime.add(const Duration(hours: 3));
      return DateFormat('HH:mm').format(turkeyTime);
    } on Exception {
      return null;
    }
  }

  Future<List<ShiftStudent>> getShift(Future<String> shiftId) async {
    var url = Uri.http(deployURL, 'shift/getShift');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'shiftID': await shiftId,
    });
    print(response.body);

    var parsed = jsonDecode(response.body);

    //Get times
    pickedUpFirst =
        makeItTime(parsed["shiftStartedAt"]) ?? "İlk öğrenci henüz alınmadı";
    pickedUpLast = makeItTime(parsed["shiftEndedAt"]) ?? "Son öğrenci alınmadı";
    h2sCompletedTime =
        makeItTime(parsed["endShiftTime"]) ?? "Servis henüz bitirilmedi";
    leftSchool = makeItTime(parsed["shiftStartedAt"]) ?? "Servis başlatılmadı";
    if (leftSchool == "Servis başlatılmadı") {
      _everyoneOnBoard = false;
    } else {
      _everyoneOnBoard = true;
      _pickedStudentCount = -parsed["studentCount"];
    }
    s2hCompletedTime =
        makeItTime(parsed["endShiftTime"]) ?? "Servis henüz bitirilmedi";

    _waitingStudentCount = parsed["studentCount"];
    _pickedStudentCount = parsed["pickedStudentCount"] ?? 0;
    parsed = parsed["students"];
    return parsed
        .map<ShiftStudent>((json) => ShiftStudent.fromJson(json))
        .toList();
  }

  Future<bool> getShiftType(Future<String> shiftId) async {
    var url = Uri.http(deployURL, 'shift/getShift');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'shiftID': await shiftId,
    });
    print(response.body);

    var parsed = jsonDecode(response.body);
    _waitingStudentCount = await parsed["studentCount"];
    _isActive = await parsed["isActive"];
    parsed = parsed["shiftName"];
    if (parsed.toString().contains("Çıkış")) {
      return false; //This is s2h
    } else {
      return true; //This is h2s
    }
  }

  void updateTimeH2S() {
    TimeOfDay time = TimeOfDay.fromDateTime(DateTime.now());
    if (_pickedStudentCount == 1) {
      setState(() {
        pickedUpFirst = time.format(context);
        onTheRoadToSchool = true;
      });
    }
    if (_waitingStudentCount == _pickedStudentCount) {
      setState(() {
        pickedUpLast = time.format(context);
      });
    }
  }

  void updateStudentStatus(String studentID, ShiftStudentStatus status) async {
    var url = Uri.http(deployURL, 'shift/updateStudentStatus');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'shiftID': await widget.shiftID,
      'studentID': studentID,
      'status': status.getEnum(),
    });
    print(response.body);
  }

  void endShift() async {
    var url = Uri.http(deployURL, 'shift/endShift');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'shiftID': await widget.shiftID,
    });
    Timer(const Duration(seconds: 1), () => _timer.cancel());
    print(response.body);
  }

  openError() => showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            title: const Text("Hata!"),
            content: const Text("Durumu \"Beklemede\" olan öğrenciler var!"),
            actions: [
              TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(COLOR_ORANGE)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Tamam"),
              )
            ],
          )));

  void sendLocation(Future<String> shiftID) async {
    var url = Uri.http(deployURL, 'location/sendLocation');
    print(url);
    Position position = await _getCurrentPosition();
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'shiftID': await shiftID,
      'lat': position.latitude.toString(),
      'lon': position.longitude.toString(),
    });
    print(response.body);
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<Position> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) {
      throw Exception("Konum izni verilmedi!");
    }
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}
