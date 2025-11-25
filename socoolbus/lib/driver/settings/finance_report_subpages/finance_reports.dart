import 'package:flutter/material.dart';
import 'package:my_app/components/general_button.dart';
import 'package:my_app/driver/settings/finance_report_subpages/expense_report_page.dart';
import 'package:my_app/driver/settings/finance_report_subpages/income_report_page.dart';

class FinanceReportGeneralPage extends StatelessWidget {
  const FinanceReportGeneralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Finans Raporları")),
        body: Center(
          child: Column(children: [
            const SizedBox(
              height: 40,
            ),
            GeneralButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const IncomeReportPage()),
                );
              },
              child: const Text("     Gelir Raporları     "),
            ),
            GeneralButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ExpenseReportPage()),
                );
              },
              child: const Text("     Gider Raporları     "),
            ),
          ]),
        ));
  }
}
