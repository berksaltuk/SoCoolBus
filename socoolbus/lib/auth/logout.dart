import 'package:shared_preferences/shared_preferences.dart';

void logout() async {
    final session = await SharedPreferences.getInstance();

    await session.clear();
}