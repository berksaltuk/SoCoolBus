import 'package:flutter/material.dart';
import 'package:my_app/auth/login.dart';
import 'package:my_app/auth/logout.dart';
import 'package:my_app/components/contact_us.dart';
import 'package:my_app/driver/settings/driver_add_student.dart';
import 'package:my_app/driver/settings/finance_report_subpages/finance_reports.dart';
import 'package:my_app/driver/settings/subscription.dart';
import 'package:my_app/driver/settings/update_password.dart';

import 'driver_add_iban.dart';
import 'driver_my_schools.dart';

class DriverSettings extends StatelessWidget {
  const DriverSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
            height: 60,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              "Ayarlar",
              style: Theme.of(context).textTheme.headline3,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.apartment),
            title: const Text('Okullarım'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DriverMySchools()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Öğrenci Ekle'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DriverAddStudent()),
            ),
          ),
          /*
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Rapor Al'),
            onTap: () => null,
          ),
          */
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('IBANlarım'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DriverAddIBAN()),
            ),
          ),
          /*
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Bildirim Ayarları'),
            onTap: () => null,
          ),
          */
          ListTile(
            leading: const Icon(Icons.price_change),
            title: const Text('Üyelik Bilgileri'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.money),
            title: const Text('Finans Raporları'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FinanceReportGeneralPage()),
            ),
          ),
          /*
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Hostes ve Yedek Şoför'),
            onTap: () => null,
          ),
          */
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('Şifremi Değiştir'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UpdatePassword()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.call),
            title: const Text('Bize Ulaşın'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactUsScreen()),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Çıkış'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () => {
              logout(),
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                  (Route<dynamic> route) => false)
            },
          ),
        ],
      ),
    );
  }
}
