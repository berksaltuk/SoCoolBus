import 'package:flutter/material.dart';
import 'package:my_app/driver/main_screens/driver_agenda_screen.dart';
import 'package:my_app/driver/main_screens/driver_finance_screen.dart';
import 'package:my_app/driver/main_screens/driver_home_screen.dart';
import 'package:my_app/driver/main_screens/driver_profile_screen.dart';
import 'package:my_app/driver/main_screens/driver_student_info_screen.dart';

// loging in as driver leads to the this page
class DriverNavigation extends StatefulWidget {
  const DriverNavigation({super.key});

  @override
  _DriverNaviState createState() => _DriverNaviState();
}

class _DriverNaviState extends State<DriverNavigation> {
  int currentIndex = 2; // default site is homescreen at index 2
  final screens = [
    DriverStudentInfoScreen(),
    DriverAgendaScreen(),
    DriverHomeScreen(),
    DriverFinanceScreen(),
    DriverProfileScreen()
  ];

  Widget build(BuildContext context) => Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.orange,
        selectedItemColor: Colors.white,
        showUnselectedLabels: true,
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            label: 'Öğrenci',
            icon: Icon(Icons.school),
          ),
          BottomNavigationBarItem(
            label: 'Ajanda',
            icon: Icon(Icons.edit_calendar_rounded),
          ),
          BottomNavigationBarItem(
            label: 'Anasayfa',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'Finans',
            icon: Icon(Icons.payments),
          ),
          BottomNavigationBarItem(
            label: 'Profil',
            icon: Icon(Icons.person),
          ),
        ],
      ));
}
