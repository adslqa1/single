import 'dart:convert';
import 'dart:io';

import 'package:cleo/constants.dart' as cons;
import 'package:cleo/cleo_device/cleo_device.dart';
import 'package:cleo/cleo_device/cleo_error.dart';
import 'package:cleo/cleo_device/cleo_state.dart';
import 'package:cleo/cleo_device/view/per_state/01.qr_scan.view.dart';

import 'package:cleo/cleo_device/view/per_state/02.cartridge_tube_open.view.dart';
import 'package:cleo/cleo_device/view/per_state/03.cartridge_swab_open.view.dart';
import 'package:cleo/cleo_device/view/per_state/04.cartridge_sample_get.view.dart';
import 'package:cleo/cleo_device/view/per_state/05.cartridge_sample_close.view.dart';
import 'package:cleo/cleo_device/view/per_state/06.cartridge_sample_mix.view.dart';
import 'package:cleo/cleo_device/view/per_state/08.cartridge_insert.view.dart';
// import 'package:cleo/cleo_device/view/per_state/08.cartridge_tube_insert.view.dart';
import 'package:cleo/cleo_device/view/per_state/09.close_cover.view.dart';
import 'package:cleo/main.dart';
import 'package:cleo/model/test_report.dart';
import 'package:cleo/provider/auth.dart';
import 'package:cleo/provider/bluetooth.provider.dart';
import 'package:cleo/screen/cartridge/result_progress.dart';
import 'package:cleo/screen/common/confirm_button.dart';
import 'package:cleo/util/device_mem.dart';
import 'package:cleo/util/notification.dart';
import 'package:cleo/util/sql_helper.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TestPrepareScreen extends StatefulWidget {
  static const routeName = '/testPrepare';

  const TestPrepareScreen({Key? key}) : super(key: key);

  @override
  State<TestPrepareScreen> createState() => _TestPrepareScreenState();
}

class _TestPrepareScreenState extends State<TestPrepareScreen> {
  CleoDevice? _crntDevice;

  bool newTestBusy = false;
  bool reconnecting = false;
  bool showingError = false;
  int? _listenerHash;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvider>(
      builder: (context, bleProvider, child) {
        if (bleProvider.currentDevice == null) {
          return const Center(child: Text('DEVICE NOT SELECTED ERROR'));
        }
        final crntDevice = bleProvider.currentDevice!;
        return ChangeNotifierProvider.value(
          value: crntDevice,
          child: Selector<CleoDevice, CleoState>(
            selector: (context, device) => device.state,
            builder: (context, state, child) {
              if (state is QrScanState) {
                return const QrScanView();
              }
              if (state is CartridgeInsertState) {
                return const CartridgeInsertView();
              }
              if (state is CartridgeTubeOpenState) {
                return const CartridgeTubeOpenView();
              }
              if (state is CartridgeSwabOpenState) {
                return const CartridgeSwabOpenView();
              }
              if (state is CartridgeSampleGetState) {
                return const CartridgeSampleGetView();
              }
              if (state is CartridgeSampleCloseState) {
                return const CartridgeSampleCloseView();
              }
              if (state is CartridgeSampleMixState) {
                return const CartridgeSampleMixView();
              }
              // if (state is CartridgeTubeInsertState) {
              //   return const CartridgeTubeInsertView();
              // }
              if (state is CloseCoverState) {
                return const CloseCoverView();
              }

              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void initListeners() {
    final crntDevice =
        Provider.of<BluetoothProvider>(context, listen: false).currentDevice;
    if (crntDevice == null) {
      return;
    }
    // if (_crntDevice == crntDevice) {
    //   // already registered
    //   return;
    // }
    Future<void> Function()? _listener;

    _listener = () async {
      if (_listener.hashCode != _listenerHash) {
        debugPrint('test_prepare :remove listener');
        crntDevice.removeListener(_listener!);
        return;
      }
      if (!mounted) {
        debugPrint('test_prepare :remove listener');
        crntDevice.removeListener(_listener!);
        return;
      }
      debugPrint('test_prepare : handleDeviceState');

      // handle conn state change
      if (!reconnecting &&
          !crntDevice.connected &&
          crntDevice.crntTesterId != null) {
        reconnecting = true;
        showReconnectDialog();
        tryReconnet(crntDevice);
      } else if (reconnecting && crntDevice.connected) {
        if (crntDevice.error is ReconnectionFailError) {
          crntDevice.updateError(null);
        }
        reconnecting = false;
      }
      // handle state change
      if (crntDevice.state is TestProgressState) {
        if (newTestBusy) return;
        setState(() {
          newTestBusy = true;
        });
        Future.delayed(const Duration(milliseconds: 1000)).then((value) {
          setState(() {
            newTestBusy = false;
          });
        });
        goProgress(context, crntDevice);
        return;
      }
      if (crntDevice.state is IdleState) {
        goHome(context);
        return;
      }

      // handle error states
      if (crntDevice.error != null && !showingError) {
        if (crntDevice.error is CartridgeMissingError && !showingError) {
          showingError = true;
          showCartridgeMissingDialog();
        } else {
          showingError = true;
          showCustomErrorDialog();
        }
      } else if (crntDevice.error == null && showingError) {
        showingError = false;
        Navigator.popUntil(context, (route) => route.settings.name != 'dialog');
      }
    };
    _listenerHash = _listener.hashCode;
    crntDevice.addListener(_listener);
    debugPrint('handleDeviceState listener init');
  }

  Future<bool> tryReconnet(CleoDevice crntDevice) async {
    bool pass = false;
    for (int i = 1; i < 5; i++) {
      pass = await crntDevice
          .connectAndPair(crntDevice.crntTesterId!)
          .then((_) => true)
          .catchError((err, trace) {
        debugPrint('failed connection :: $i');
        return false;
      });

      if (pass) {
        break;
      }
    }
    if (!pass) {
      await crntDevice.connectAndPair(crntDevice.crntTesterId!).catchError(
          (err, trace) => crntDevice.updateError(ReconnectionFailError('')));
    }
    return pass;
  }

  Future showReconnectDialog() {
    final crntDevice =
        Provider.of<BluetoothProvider>(context, listen: false).currentDevice!;

    return showDialog(
      routeSettings: const RouteSettings(name: 'conn_dialog'),
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    color: Color.fromRGBO(240, 151, 0, 1),
                    size: 130,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'WARNING',
                    style: TextStyle(
                      color: Color(0xffC20018),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bluetooth connection lost!',
                    style: TextStyle(
                      color: Color(0xffCC6116),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: FlatConfirmButton(
                      onPressed: () {
                        showConfirmCancel();
                      },
                      label: 'CANCEL TEST',
                      reversal: true,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: crntDevice,
                    builder: (context, _) {
                      if (!crntDevice.connected &&
                          crntDevice.error is! ReconnectionFailError) {
                        return const SizedBox(height: 8);
                      }

                      return Container(
                        margin: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                        child: FlatConfirmButton(
                          onPressed: () {
                            Navigator.popUntil(
                                context,
                                (route) =>
                                    route.settings.name != 'conn_dialog');
                          },
                          label: 'BACK TO RECONNECTION',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future showCartridgeMissingDialog() {
    final crntDevice =
        Provider.of<BluetoothProvider>(context, listen: false).currentDevice!;

    return showDialog(
      context: context,
      barrierDismissible: false,
      routeSettings: const RouteSettings(name: 'cartridge_dialog'),
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    color: Color.fromRGBO(240, 151, 0, 1),
                    size: 130,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'WARNING',
                    style: TextStyle(
                      color: Color(0xffC20018),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'KEEP YOUR TEST CARTRIDGE INSERTED.',
                    style: TextStyle(
                      // color: Color(0xffCC6116),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FlatConfirmButton(
                    onPressed: () {
                      crntDevice.state.cancelTest();
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    label: 'CANCEL TEST',
                  ),
                  AnimatedBuilder(
                    animation: crntDevice,
                    builder: (context, _) {
                      if (crntDevice.hasError &&
                          crntDevice.error is CartridgeMissingError) {
                        return const SizedBox(height: 8);
                      }

                      return Container(
                        margin: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                        child: FlatConfirmButton(
                          onPressed: () {
                            Navigator.popUntil(
                                context,
                                (route) =>
                                    route.settings.name != 'cartridge_dialog');
                          },
                          label: 'BACK TO TEST',
                          reversal: true,
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future showCustomErrorDialog() {
    final crntDevice =
        Provider.of<BluetoothProvider>(context, listen: false).currentDevice!;

    return showDialog(
      routeSettings: const RouteSettings(name: 'err_dialog'),
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    color: Color.fromRGBO(240, 151, 0, 1),
                    size: 130,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ERROR',
                    style: TextStyle(
                      color: Color(0xffC20018),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${crntDevice.error?.desc}',
                    style: const TextStyle(
                      color: Color(0xffCC6116),
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                        backgroundColor:
                            MaterialStateProperty.all(const Color(0xffDA930F)),
                      ),
                      onPressed: () {
                        crntDevice.disconnect();
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        width: double.infinity,
                        child: const Center(
                          child: Text(
                            'CANCEL TEST',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> goProgress(BuildContext context, CleoDevice device) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    // final userName = auth.displayName;
    final crntTester = auth.currentTester!;
    final crntCartridge = device.crntCartridge!;
    final deviceInfo = DeviceInfoPlugin();
    String? deviceName;
    if (Platform.isIOS) {
      deviceName = (await deviceInfo.iosInfo).utsname.machine.toString();
    } else if (Platform.isAndroid) {
      deviceName = (await deviceInfo.androidInfo).model.toString();
    }

    final initReport = TestReport(
      userId: crntTester.id,
      name: crntTester.name,
      testType: crntCartridge.testType,
      birthday: crntTester.birthday,
      gender: crntTester.gender,
      macAddress: device.device.id.toString(),
      serial: device.serial,
      expire: crntCartridge.expDate,
      lotNum: crntCartridge.lotNum,
      ctValue: crntCartridge.ctValue,
      reportStatus: ReportStatus.running,
    );

    initReport.deviceName = deviceName;
    initReport.startAt = DateTime.now().toIso8601String();
    final reportId = await SqlReport.insertReport(initReport);
    initReport.id = reportId;
    // device.crntReport = initReport;
    DeviceMem.setRunningReportId(crntTester.id, reportId);

    final testInfo = initReport.toJson();

    if (crntTester.name == 'test_user') {
      LocalNotification.sendScheduleMsg(
        title: 'Test Complete',
        body: '${crntTester.name}`s Test Complete',
        id: crntTester.id,
        payload: jsonEncode(testInfo),
        duration: const Duration(minutes: 3),
      );
    } else {
      LocalNotification.sendScheduleMsg(
        title: 'Test Complete',
        body: '${crntTester.name}`s Test Complete',
        id: crntTester.id,
        payload: jsonEncode(testInfo),
        duration: const Duration(minutes: 30),
      );
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => ResultProgressScreen(reportId: reportId),
      ),
      (route) => route.isFirst,
    );
  }

  void goHome(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void showConfirmCancel() {
    final crntDevice =
        Provider.of<BluetoothProvider>(context, listen: false).currentDevice!;

    showDialog(
      barrierDismissible: false,
      context: context,
      routeSettings: const RouteSettings(name: 'dialog'),
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.exclamationmark_triangle,
                  color: Color.fromRGBO(240, 151, 0, 1),
                  size: 130,
                ),
                const SizedBox(height: 16),
                const Text(
                  'CANCEL TEST',
                  style: TextStyle(
                    color: Color(0xffC20018),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Are you sure you want to stop testing?',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xffCC6116),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Once testing is discontinued, used kits cannot be reused.',
                    style: TextStyle(fontSize: 18, color: Color(0xffDA930F)),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: FlatConfirmButton(
                      onPressed: () {
                        crntDevice.disconnect();
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      label: 'CANCEL TEST',
                    )),
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: FlatConfirmButton(
                      onPressed: () => Navigator.of(context).pop(),
                      label: 'BACK TO TEST',
                      reversal: true,
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}
