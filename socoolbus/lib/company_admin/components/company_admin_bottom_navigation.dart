import 'package:flutter/material.dart';

import '../main_screens/bus_info.dart';
import '../main_screens/bus_status.dart';
import '../main_screens/home_screen.dart';
import '../main_screens/settings.dart';
import '../main_screens/students_info.dart';

// loging in as school admin leads to the this page
class CompanyAdminNavigation extends StatefulWidget {
  const CompanyAdminNavigation({super.key});

  @override
  _CompanyAdminNaviState createState() => _CompanyAdminNaviState();
}

class _CompanyAdminNaviState extends State<CompanyAdminNavigation> {
  int currentIndex = 1; // default site is homescreen at index 2
  final screens = [
    CompanyAdminStudentsInfo(),
    CompanyAdminBusInfo(),
    CompanyAdminHomeScreen(),
    CompanyAdminBusStatus(),
    CompanyAdminSettings()
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
            icon: Icon(Icons.person),
          ),
          BottomNavigationBarItem(
            label: 'Servis',
            icon: Icon(Icons.drive_eta),
          ),
          BottomNavigationBarItem(
            label: 'Anasayfa',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'Liste',
            icon: Icon(Icons.list),
          ),
          BottomNavigationBarItem(
            label: 'Ayarlar',
            icon: Icon(Icons.settings),
          ),
        ],
      ));
}
