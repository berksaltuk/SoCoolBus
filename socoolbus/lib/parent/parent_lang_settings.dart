import 'package:flutter/material.dart';

import '../components/parent_bottom_navigation.dart';

enum Lang { en, tr }

class ParentLangSettings extends StatefulWidget {
  const ParentLangSettings({super.key});

  @override
  State<ParentLangSettings> createState() => _ParentSettingsLangState();
}

class _ParentSettingsLangState extends State<ParentLangSettings> {
  Lang _site = Lang.en;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dil Ayarları"),
      ),
      body: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              ListTile(
                title: const Text('English'),
                leading: Radio(
                  activeColor: Colors.orange,
                  value: Lang.en,
                  groupValue: _site,
                  onChanged: (value) {
                    setState(() {
                      _site = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Türkçe'),
                leading: Radio(
                  activeColor: Colors.orange,
                  value: Lang.tr,
                  groupValue: _site,
                  onChanged: (value) {
                    setState(() {
                      _site = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      //bottomNavigationBar: const ParentNavigation()
    );
  }
}
