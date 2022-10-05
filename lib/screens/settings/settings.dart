import 'package:flutter/material.dart';
import '../../constants.dart';
import 'components/settings_body.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        backgroundColor: refreshIndicatorBackgroundColor,
        color: refreshIndicatorForegroundColor,
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: const SafeArea(
              child: SettingsBody(),
            ),
          ),
        ),
      ),
    );
  }
}
