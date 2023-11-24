import 'package:cleo/provider/auth.dart';
import 'package:cleo/screen/common/custom_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

const defaultPadding = 32.0;

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Setting',
        useBack: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 16, horizontal: defaultPadding),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color.fromARGB(255, 184, 184, 184)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'App version',
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                  Text('0.0.1'),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  routeSettings: const RouteSettings(name: 'dialog'),
                  builder: (context) => AlertDialog(
                    content: const Text('Are you sure ?'),
                    actions: [
                      TextButton(
                        child: const Text(
                          "CONFIRM",
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);

                          Provider.of<AuthProvider>(context, listen: false)
                              .logout();
                        },
                      ),
                      TextButton(
                        child: const Text("CANCEL"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: defaultPadding),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom:
                        BorderSide(color: Color.fromARGB(255, 184, 184, 184)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                    Icon(CupertinoIcons.right_chevron),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  routeSettings: const RouteSettings(name: 'dialog'),
                  builder: (context) => AlertDialog(
                    content: const Text('Are you sure ?'),
                    actions: [
                      TextButton(
                        child: const Text(
                          "CONFIRM",
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {},
                      ),
                      TextButton(
                        child: const Text("CANCEL"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: defaultPadding),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom:
                        BorderSide(color: Color.fromARGB(255, 184, 184, 184)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Delete account',
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                    Icon(CupertinoIcons.right_chevron),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRowWiget(String label, {Function? onTap}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color.fromARGB(255, 184, 184, 184)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 22,
            ),
          ),
          const Icon(CupertinoIcons.right_chevron),
        ],
      ),
    );
  }
}
