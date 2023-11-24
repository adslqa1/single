import 'dart:io';

import 'package:cleo/main.dart';
import 'package:cleo/provider/auth.dart';
import 'package:cleo/provider/bluetooth.provider.dart';
import 'package:cleo/screen/common/confirm_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:cleo/constants.dart' as cons;

class FindDeviceScreen extends StatefulWidget {
  const FindDeviceScreen({Key? key}) : super(key: key);

  @override
  State<FindDeviceScreen> createState() => _FindDeviceScreenState();
}

class _FindDeviceScreenState extends State<FindDeviceScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvider>(
      builder: (context, BluetoothProvider bluetoothProvider, child) {
        final crntDevice = bluetoothProvider.currentDevice;
        final List<DeviceListItem> itemList = bluetoothProvider.getDeviceList();

        return Container(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              if (itemList.isNotEmpty || bluetoothProvider.isScanning)
                const Text(
                  'Select your CLEO ONE device',
                  style: TextStyle(
                    color: Color(0xff717071),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 4),
              SizedBox(
                height: 16,
                child: bluetoothProvider.isScanning
                    ? const Center(child: LinearProgressIndicator())
                    : null,
              ),
              Expanded(
                child: itemList.isEmpty && !bluetoothProvider.isScanning
                    ? SingleChildScrollView(
                        child: buildNoDeviceText(context),
                      )
                    : ListView.builder(
                        itemCount: itemList.length,
                        itemBuilder: (context, index) {
                          final item = itemList[index];
                          final connected = item.connected;
                          final device = item.device;

                          bool paired = connected &&
                              crntDevice != null &&
                              device.id.toString() ==
                                  crntDevice.device.id.toString();

                          String deviceSerial = '';
                          if (paired) {
                            deviceSerial = crntDevice.serial;
                          }

                          return InkWell(
                            onTap: () async {
                              // if (paired) {
                              //   MyApp.showSnackBar('Already connected');
                              //   return;
                              // }
                              if (paired) {
                                await actionDisconnectDevice(context, device);
                              } else {
                                await actionConnectDevice(context, device);
                              }
                            },
                            child:
                                buildDeviceButton(paired, device, deviceSerial),
                          );
                        },
                      ),
              ),
              if (itemList.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  child: const Text(
                    'Select your CLEO ONE device.\nMake sure that the number of the selected device matches the serial number(SN) found on your CLEO ONE device.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              itemList.isEmpty && !bluetoothProvider.isScanning
                  ? FlatConfirmButton(
                      onPressed: () => Navigator.of(context).pop(),
                      label: 'BACK',
                    )
                  : ConfirmButton(
                      onPressed: () {
                        if (!bluetoothProvider.isScanning) {
                          bluetoothProvider.scan(
                              timeout: const Duration(seconds: 10));
                        }
                      },
                      label: 'FIND DEVICE',
                      child: bluetoothProvider.isScanning
                          ? const CupertinoActivityIndicator(
                              color: Colors.white)
                          : null,
                    ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Container buildDeviceButton(
    bool connected,
    BluetoothDevice device,
    String deviceSerial,
  ) {
    String deviceName, serial;
    if (RegExp('-').allMatches(device.name).length > 1) {
      // 구버전펌웨어 기기도 연동하기 위함
      deviceName =
          device.name.replaceAll(RegExp('[^CLEO]'), '').trim() + ' ONE ' + '';
      serial = deviceSerial;
      if (deviceSerial.isEmpty) {
        serial = device.name.replaceAll(RegExp('[CLEO]'), '').trim();
        // deviceName += serial.replaceAll(RegExp('.+(?<=-)'), '');
      }
    } else {
      deviceName = device.name;
      serial = deviceSerial;
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: connected ? cons.primary : Colors.grey,
        ),
        borderRadius: BorderRadius.circular(8),
        color: connected ? cons.primary : Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                deviceName,
                style: TextStyle(
                  color: connected ? Colors.white : const Color(0xff717071),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                serial,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: connected ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          (deviceSerial.isEmpty)
              ? IconButton(
                  color: Colors.black,
                  onPressed: () {
                    actionConnectDevice(context, device);
                  },
                  icon: const Icon(Icons.touch_app,
                      color: Color(0xff717071), size: 37),
                )
              : IconButton(
                  color: Colors.black,
                  onPressed: () {
                    actionDisconnectDevice(context, device);
                  },
                  icon: const Icon(Icons.sync_disabled,
                      color: Colors.white, size: 37),
                ),
        ],
      ),
    );
  }

  actionConnectDevice(BuildContext _context, BluetoothDevice device) async {
    final bluetoothProvider =
        Provider.of<BluetoothProvider>(_context, listen: false);
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentTester == null) {
      MyApp.showSnackBar('Please Select Tester First');
      return;
    }

    final testerId = authProvider.currentTester!.id;

    showDialog(
      context: _context,
      barrierDismissible: true,
      routeSettings: const RouteSettings(name: 'dialog'),
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: const [
                CupertinoActivityIndicator(),
                SizedBox(width: 16),
                Text('Pairing...'),
              ],
            ),
          ),
        );
      },
    );
    try {
      await bluetoothProvider.connect(device, testerId);
    } catch (err) {
      device.disconnect();
      print(err.toString());
      MyApp.showSnackBar('ERROR : Fail to Connect');
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  actionDisconnectDevice(BuildContext context, BluetoothDevice device) async {
    final bluetoothProvider =
        Provider.of<BluetoothProvider>(context, listen: false);
    if (bluetoothProvider.currentDevice?.device.id == device.id) {
      await bluetoothProvider.disconnect();
    } else {
      await device.disconnect();
    }
    bluetoothProvider.refreshConnected();
  }

  buildNoDeviceText(BuildContext context) {
    const style = TextStyle(fontSize: 16, color: Colors.black);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          CupertinoIcons.exclamationmark_triangle,
          color: Color.fromRGBO(240, 151, 0, 1),
          size: 130,
        ),
        const SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: style,
            children: [
              TextSpan(
                text: 'NO CLEO ONE DEVICES FOUND',
                style: TextStyle(
                  color: Color(0xffC20018),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: '\n\n'),
              TextSpan(
                text:
                    'Make sure your CLEO ONE device is next to your smart device when trying to connect. Check that your CLEO ONE device is turned ON (this LED light should be orange).\n If you do not have a CLEO ONE device and cartridge, you can purchase one at https://cleo1.net. ',
                // style: TextStyle(color: Color(0xffCC6116)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
