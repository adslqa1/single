import 'package:cleo/constants.dart' as constant;
import 'package:cleo/screen/auth/disclaimer.dart';
import 'package:flutter/material.dart';

class PermissionNoticeScreen extends StatelessWidget {
  const PermissionNoticeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Access Permissions',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'The access permissions below listed are required for the complete use of CLEO ONE Test and Service.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              children: const [
                PermissionItem(
                  icon: Icons.location_on_outlined,
                  title: 'GPS and Location (Required)',
                  desc:
                      'The CLEO™ ONE app collects location data even when the app is shut down or not in use, and the location data is used to connect the CLEO™ ONE device via the BLE',
                ),
                PermissionItem(
                  icon: Icons.bluetooth,
                  title: 'Bluetooth (Required)',
                  desc:
                      'Used to connect CLEO™ ONE device via BLE to your mobile device.',
                ),
                PermissionItem(
                  icon: Icons.camera_alt_outlined,
                  title: 'Camera (Required)',
                  desc: 'Used to scan codes',  //2023.10.16_CJH
                ),
                PermissionItem(
                  icon: Icons.storage_outlined,
                  title: 'Storage (Required)',
                  desc:
                      'Used to store Test results transmitted from CLEO ONE. this may include user information',
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return Scaffold(
                        appBar: AppBar(),
                        body: Padding(
                          padding: const EdgeInsets.all(16),
                          child: SingleChildScrollView(
                            child: Disclaimer.privacy(),
                          ),
                        ),
                      );
                    },
                  ));
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  child: Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 16,
                      color: constant.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: GestureDetector(
              child: Container(
                width: size.width * 0.7,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: constant.primary,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Center(
                  child: Text(
                    'CONFIRM',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          )
        ],
      ),
    );
  }
}

class PermissionItem extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;

  const PermissionItem(
      {Key? key, required this.title, required this.desc, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
            child: Icon(
              icon,
              size: 40,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
