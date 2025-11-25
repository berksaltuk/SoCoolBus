import 'package:flutter/material.dart';

import '../parent/parent_home_screen.dart';
import '../parent/parent_payment_screen.dart';
import '../parent/parent_permission.dart';
import '../parent/parent_reports.dart';
import '../parent/parent_settings.dart';

class ParentNavigation extends StatefulWidget {
  const ParentNavigation({super.key});

  @override
  _ParentNaviState createState() => _ParentNaviState();
}

class _ParentNaviState extends State<ParentNavigation> {
  int _currentIndex = 0;
  int currentIndex = 2; // default site is homescreen at index 2
  final screens = [
    const ParentReportsScreen(),
    const ParentPermissionScreen(),
    const ParentHomeScreen(),
    const ParentPaymentScreen(), // Ödemeler olucak
    const ParentSettingsScreen()
  ];

  Widget build(BuildContext context) => Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.amber,
        selectedItemColor: Colors.white,
        showUnselectedLabels: true,
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            label: 'Raporlar',
            icon: Icon(Icons.history),
          ),
          BottomNavigationBarItem(
            label: '\t\t\t\tİzin\nİşlemleri',
            icon: Icon(Icons.edit_calendar_rounded),
          ),
          BottomNavigationBarItem(
            label: 'Anasayfa',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'Ödemeler',
            icon: Icon(Icons.payments),
          ),
          BottomNavigationBarItem(
            label: 'Ayarlar',
            icon: Icon(Icons.settings),
          ),
        ],
      ));
}

ThemeData _buildShrineTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    colorScheme: _shrineColorScheme,
    textTheme: _buildShrineTextTheme(base.textTheme),
  );
}

TextTheme _buildShrineTextTheme(TextTheme base) {
  return base
      .copyWith(
        caption: base.caption!.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          letterSpacing: defaultLetterSpacing,
        ),
        button: base.button!.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: defaultLetterSpacing,
        ),
      )
      .apply(
        fontFamily: 'Rubik',
        displayColor: shrineBrown900,
        bodyColor: shrineBrown900,
      );
}

const ColorScheme _shrineColorScheme = ColorScheme(
  primary: shrinePink100,
  primaryVariant: shrineBrown900,
  secondary: shrinePink50,
  secondaryVariant: shrineBrown900,
  surface: shrineSurfaceWhite,
  background: shrineBackgroundWhite,
  error: shrineErrorRed,
  onPrimary: shrineBrown900,
  onSecondary: shrineBrown900,
  onSurface: shrineBrown900,
  onBackground: shrineBrown900,
  onError: shrineSurfaceWhite,
  brightness: Brightness.light,
);

const Color shrinePink50 = Color(0xFFFEEAE6);
const Color shrinePink100 = Color(0xFFFEDBD0);
const Color shrinePink300 = Color(0xFFFBB8AC);
const Color shrinePink400 = Color(0xFFEAA4A4);

const MaterialColor shrineBrown900 = Colors.yellow; //Color(0xFF442B2D);
const Color shrineBrown600 = Color(0xFF7D4F52);

const Color shrineErrorRed = Color(0xFFC5032B);

const Color shrineSurfaceWhite = Color(0xFFFFFBFA);
const Color shrineBackgroundWhite = Colors.white;

const defaultLetterSpacing = 0.03;
