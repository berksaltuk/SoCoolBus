import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:my_app/auth/login.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.remove();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SoCoolBus());
}

Future initialization(BuildContext? context) async {
  await Future.delayed(const Duration(seconds: 3));
}

class SoCoolBus extends StatelessWidget {
  const SoCoolBus({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const MaterialColor white = MaterialColor(
      0xFFFFFFFF,
      <int, Color>{
        50: Color(0xFFFFFFFF),
        100: Color(0xFFFFFFFF),
        200: Color(0xFFFFFFFF),
        300: Color(0xFFFFFFFF),
        400: Color(0xFFFFFFFF),
        500: Color(0xFFFFFFFF),
        600: Color(0xFFFFFFFF),
        700: Color(0xFFFFFFFF),
        800: Color(0xFFFFFFFF),
        900: Color(0xFFFFFFFF),
      },
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SoCoolBus',
      routes: {
        '/login': (context) => LoginPage(),
        //'/startShift': (context) => DriverStartShift(),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', ''),
        Locale('en', ''),
      ],
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          appBarTheme: AppBarTheme(backgroundColor: COLOR_WHITE),
          //added for DatePicker
          buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.accent),
          primaryColor: Colors.black,
          textTheme: const TextTheme(
            headline1: TextStyle(
                color: COLOR_BLACK,
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins'),
            headline2: TextStyle(
                color: COLOR_BLACK,
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins'),
            headline3: TextStyle(
                color: COLOR_BLACK,
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins'),
            bodyText1: TextStyle(
                color: COLOR_DARK_GREY,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins'),
            bodyText2: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins'),
          ),
          primarySwatch: white,
          scaffoldBackgroundColor: COLOR_BG_LIGHT),
      home: LoginPage(),
    );
  }
}
