import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:app_settings/app_settings.dart';
import 'package:package_info/package_info.dart';
import 'package:cleo/cleo_device/cleo_device.dart';
import 'package:cleo/cleo_device/cleo_state.dart';
import 'package:cleo/cleo_device/view/test_prepare.dart';
import 'package:cleo/constants.dart' as cons;
import 'package:cleo/main.dart';
import 'package:cleo/model/tester.dart';
import 'package:cleo/provider/auth.dart';
import 'package:cleo/provider/bluetooth.provider.dart';
import 'package:cleo/screen/cartridge/result_progress.dart';
import 'package:cleo/screen/home/debug_blue.dart';
import 'package:cleo/screen/home/delete_account.dart';
import 'package:cleo/screen/home/find_device.dart';
import 'package:cleo/screen/home/permission_notice.dart';
import 'package:cleo/screen/report/list.dart';
import 'package:cleo/util/device_mem.dart';
import 'package:cleo/util/notification.dart';
import 'package:cleo/util/sql_helper.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import '../auth/disclaimer.dart';
import '../common/confirm_button.dart';
import '../report/noti_handle.dart';
import 'tester_manage.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static final GlobalKey<_MainScreenState> _mainScreenKey =
      GlobalKey<_MainScreenState>();
  final LocalAuthentication auth = LocalAuthentication();
  var autoRouteListener;
  bool newTestBusy = false;
  bool asking = false;
  bool showNotice = true;
  late String packageInfoVersion;

  @override
  void initState() {
    super.initState();
    LocalNotification.flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails()
        .then(
      (NotificationAppLaunchDetails? details) {
        if (details!.didNotificationLaunchApp) {
          if (details.payload == null) {
            return;
          }
          Map json = jsonDecode(details.payload!);
          Navigator.of(context).pushNamed(
            NotiHandleScreen.routeName,
            arguments: NotiHandleScreenArguments(json),
          );
        }
      },
    );
    _initializeInfo();
  }

  Future<dynamic> _initializeInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    packageInfoVersion = packageInfo.version.toString();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(
      const Duration(seconds: 1),
      () => checkPermissionAndRequest(),
    );
    initAutoRouteListener();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Consumer<AuthProvider>(
      key: _mainScreenKey,
      builder: (context, AuthProvider _authProvider, child) {
        String userName = ', ${_authProvider.displayName}';
        return Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            SizedBox(
                              height: constraints.maxHeight * 0.1,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Welcome$userName',
                                      style: const TextStyle(
                                        color: cons.primary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 24,
                                      ),
                                    ),
                                    buildPopupWidget(),
                                  ],
                                ),
                              ),
                            ),
                            Consumer<BluetoothProvider>(
                              builder: (context, btProvider, _) {
                                bool connected = false;
                                String deviceId = '';

                                if (btProvider.currentDevice != null) {
                                  connected =
                                      btProvider.currentDevice!.connected;
                                }

                                bool testButtonActive =
                                    btProvider.currentDevice?.crntTesterId !=
                                            null &&
                                        connected;
                                return Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'PROFILE & DEVICE',
                                        style: cons.subLabelStyle,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Who will take the test now?',
                                        style: TextStyle(
                                          color: cons.grey,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Column(
                                        children: [
                                          InkWell(
                                            onTap: () => pairUserAction(),
                                            child: buildStatusInfo(
                                              svgPath: _authProvider
                                                          .currentTester !=
                                                      null
                                                  ? 'assets/images/user_on.svg'
                                                  : 'assets/images/user_off.svg',
                                              label: _authProvider
                                                      .currentTester?.name ??
                                                  'Specify tester',
                                              isActive:
                                                  _authProvider.currentTester !=
                                                      null,
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 8,
                                                ),
                                                child: Text(
                                                  'Select Test taker?',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                              'You should add or select test taker’s name'),
                                          const SizedBox(height: 10),
                                          InkWell(
                                            onTap: () => findDeviceBtn(context),
                                            child: buildStatusInfo(
                                              svgPath: connected
                                                  ? 'assets/images/device_on.svg'
                                                  : 'assets/images/device_off.svg',
                                              label: connected
                                                  ? 'Connected'
                                                  : 'Disconnected',
                                              isActive: connected,
                                              child: btProvider.currentDevice !=
                                                      null
                                                  ? AnimatedBuilder(
                                                      animation: btProvider
                                                          .currentDevice!,
                                                      builder: (context, _) {
                                                        deviceId = btProvider
                                                            .currentDevice!
                                                            .serial;
                                                        return Text(
                                                          connected
                                                              ? deviceId
                                                              : '',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.black,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                          ),
                                                        );
                                                      })
                                                  : Text(
                                                      connected ? deviceId : '',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 64),
                                      Row(
                                        children: [
                                          buildMainButton(
                                            iconPath:
                                                'assets/images/play_icon.svg',
                                            label: 'NEW TEST',
                                            size: size.width / 8,
                                            fontSize: constraints.maxWidth < 365
                                                ? constraints.maxWidth * 0.04
                                                : 16,
                                            isActive: testButtonActive,
                                            btnColor: const Color(0xff45CFFF),
                                            onTap: () => newTestButtonAction(
                                              context,
                                              _authProvider,
                                              btProvider,
                                            ),
                                          ),
                                          const SizedBox(width: 36),
                                          buildMainButton(
                                            iconPath:
                                                'assets/images/folder_icon.svg',
                                            label: 'VIEW RESULTS',
                                            btnColor: const Color(0xff84A0FD),
                                            size: size.width / 8,
                                            fontSize: constraints.maxWidth < 365
                                                ? constraints.maxWidth * 0.04
                                                : 16,
                                            isActive: true,
                                            onTap: () =>
                                                pushLoadDataScreen(context),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            // buildDebugButton(context),
                            Consumer<BluetoothProvider>(
                              builder: (context, btProvider, _) {
                                bool connected = false;

                                if (btProvider.currentDevice != null) {
                                  connected =
                                      btProvider.currentDevice!.connected;
                                }

                                return !connected
                                    ? Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 50,
                                          top: 32,
                                        ),
                                        child: FlatConfirmButton(
                                          onPressed: () =>
                                              findDeviceBtn(context),
                                          label: 'FIND DEVICE',
                                        ),
                                      )
                                    : InkWell(
                                        onTap: () => findDeviceBtn(context),
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 50, top: 32),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          child: const Text(
                                            'CHANGE DEVICE',
                                            style: TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                                fontSize: 18,
                                                color: Color(0xff717071)),
                                          ),
                                        ),
                                      );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Row buildDebugButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () async {
            final ble = FlutterBluePlus.instance;
            final plugin = DeviceInfoPlugin();
            String msg = (await plugin.androidInfo).toMap().toString();
            print(msg);
            // MyApp.showSnackBar(msg)
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (ctx) {
            //       return const DebugBlueScreen();
            //     },
            //   ),
            // );
          },
          child: const Text('debug'),
        ),
        ElevatedButton(
          onPressed: () {
            Map testData = {
              'id': 1,
              'name': 'User1',
              'macAddress': 'DE:93:13:F6:6B:AE',
            };

            LocalNotification.sendScheduleMsg(
              title: 'Test Complete',
              body: 'User1 Test Complete',
              id: 1,
              payload: jsonEncode(testData),
              duration: const Duration(seconds: 3),
            );
          },
          child: const Text('noti'),
        ),
      ],
    );
  }

  void pairUserAction() async {
    debugPrint('user pair');
    final crntTester = await selectTester();
    if (crntTester == null) {
      return;
    }
    final crntDevice =
        Provider.of<BluetoothProvider>(context, listen: false).currentDevice;
    if (crntDevice == null) {
      return;
    }
    // if (crntDevice.state is IdleState) {
    //   await setAutoRouting(crntDevice, crntTester.id);
    //   return;
    // }
  }

  Future selectUserAction(int userId) async {
    final crntDevice =
        Provider.of<BluetoothProvider>(context, listen: false).currentDevice;
    if (crntDevice == null) {
      throw 'Device is not Paired';
    }
    print('crntDeviceState ${crntDevice.state}');
    if (crntDevice.state is IdleState) {
      crntDevice.updateState(UserSelectState(crntDevice, ''));
    }

    if (crntDevice.state is UserSelectState) {
      await (crntDevice.state as UserSelectState).selectUser(userId);
    }
  }

  Future<Tester?> selectTester() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TesterMangeScreen(),
        fullscreenDialog: true,
        settings: const RouteSettings(name: TesterMangeScreen.routeName),
      ),
    );
    final crntTester =
        Provider.of<AuthProvider>(context, listen: false).currentTester;
    return crntTester;
  }

  Future<void> newTestButtonAction(
    BuildContext context,
    AuthProvider authProvider,
    BluetoothProvider bluetoothProvider,
  ) async {
    if (newTestBusy) return;

    setState(() {
      newTestBusy = true;
    });

    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      setState(() {
        newTestBusy = false;
      });
    });

    if (authProvider.currentTester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to select user to proceed TEST'),
          duration: Duration(milliseconds: 500),
        ),
      );
      return;
    }
    if (bluetoothProvider.currentDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('You need to connect your CLEO ONE device to proceed TEST'),
          duration: Duration(milliseconds: 500),
        ),
      );
      return;
    }

    if (!bluetoothProvider.currentDevice!.connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Device is not connected.'),
          duration: Duration(milliseconds: 500),
        ),
      );
      return;
    }

    final Size size = MediaQuery.of(context).size;

    final bool confirm = await showDialog(
      context: context,
      barrierDismissible: false,
      routeSettings: const RouteSettings(name: 'dialog'),
      builder: (context) => Dialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => Navigator.of(context).pop(false),
              child: const Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Icon(
                    CupertinoIcons.clear,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'USER CONFIRMATION',
              style: TextStyle(color: cons.primary, fontSize: 24),
            ),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: const Text(
                'Select the name of the person being tested today.',
                style: TextStyle(fontSize: 17),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color.fromARGB(255, 121, 121, 121)),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
              child: InkWell(
                onTap: () {
                  selectTester();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/user_on.svg',
                          height: 32,
                        ),
                        const SizedBox(width: 16),
                        Consumer<AuthProvider>(
                          builder: (context, provider, _) {
                            return Text(
                              provider.currentTester!.name,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            FlatConfirmButton(
              onPressed: () => Navigator.of(context).pop(true),
              label: 'CONFIRM',
              width: size.width * 0.5,
            ),
            const SizedBox(height: 24),
            FlatConfirmButton(
              onPressed: () => Navigator.of(context).pop(false),
              label: 'BACK',
              width: size.width * 0.5,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );

    if (!confirm) {
      return;
    }
    await Future.delayed(const Duration(milliseconds: 200), () async {
      final crntTester = authProvider.currentTester!;
      final device = bluetoothProvider.currentDevice!;
      if (device.state is! IdleState) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device is In Use'),
            duration: Duration(milliseconds: 500),
          ),
        );
        return;
      }
      await selectUserAction(crntTester.id);
    });
  }

  Widget buildUserStatusInfo({
    required IconData iconData,
    required String label,
    bool isActive = false,
    Widget? child,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color.fromARGB(255, 121, 121, 121)),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                iconData,
                size: 34,
                color: isActive
                    ? cons.primary
                    : const Color.fromARGB(255, 167, 167, 167),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? Colors.black
                      : const Color.fromARGB(255, 167, 167, 167),
                ),
              ),
            ],
          ),
          if (child != null) child
        ],
      ),
    );
  }

  Widget buildStatusInfo({
    required String svgPath,
    required String label,
    bool isActive = false,
    Widget? child,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color.fromARGB(255, 121, 121, 121)),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                svgPath,
                height: 32,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                  color: isActive
                      ? Colors.black
                      : const Color.fromARGB(255, 167, 167, 167),
                ),
              ),
            ],
          ),
          if (child != null) child
        ],
      ),
    );
  }

  Widget buildMainButton({
    required String iconPath,
    required Function onTap,
    Color btnColor = cons.primary,
    double size = 24,
    double fontSize = 16,
    String label = '',
    bool isActive = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => onTap(),
        child: AspectRatio(
          aspectRatio: 57 / 64,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive ? btnColor : const Color(0xffCCDCF4),
              borderRadius: BorderRadius.circular(16),
              // boxShadow: [
              //   if (isActive)
              //     BoxShadow(
              //       color: btnColor.withOpacity(0.5),
              //       offset: const Offset(0, 3),
              //       blurRadius: 8,
              //       spreadRadius: 1,
              //     )
              //   else
              //     const BoxShadow(
              //       color: Color(0xffCCDCF4),
              //       offset: Offset(0, 3),
              //       blurRadius: 8,
              //       spreadRadius: 1,
              //     )
              // ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: SvgPicture.asset(
                    iconPath,
                    width: size,
                  ),
                ),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void pushLoadDataScreen(BuildContext context) async {
    bool isSupport = await auth.isDeviceSupported();

    if (!isSupport) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'This device is not supported. Please register for biometric recognition.'),
      ));
      return;
    }

    // bool canCheckBiometrics = await auth.canCheckBiometrics;

    // print('canCheckBiometrics:: $canCheckBiometrics');

    // if (!canCheckBiometrics) {
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //     content: Text('This device is not supported'),
    //   ));
    //   return;
    // }

    // List<BiometricType> availableBiometrics =
    //     await auth.getAvailableBiometrics();

    // if (Platform.isIOS) {
    //   if (availableBiometrics.contains(BiometricType.face)) {
    //     // Face ID.
    //   } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
    //     // Touch ID.
    //   }
    // }

    // print(availableBiometrics);
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Used to verify your identity',
        // options: const AuthenticationOptions(
        //   useErrorDialogs: false,
        //   stickyAuth: false,
        //   biometricOnly: false,
        //   sensitiveTransaction: false,
        // ),
        useErrorDialogs: true,
        stickyAuth: true,
      );

      if (authenticated) {
        Navigator.of(context).pushNamed(ReportListScreen.routeName);
      }
      debugPrint('authenticated: $authenticated');
      return;
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        // Handle this exception here.
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'This device is not supported. Please register for biometric recognition.'),
        ));
      }
    }

    // bool authenticated = await auth.authenticate(
    //     localizedReason:
    //         'Scan your fingerprint (or face or whatever) to authenticate',
    //     useErrorDialogs: true,
    //     stickyAuth: true,
    //     biometricOnly: true);
  }

  void findDeviceBtn(BuildContext context) async {
    await checkPermissionAndRequest();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentTester == null) {
      MyApp.showSnackBar(
          'You need to select an user before connecting a Device');
      return;
    }

    final bluetoothProvider =
        Provider.of<BluetoothProvider>(context, listen: false);

    bool isBluetoothOn = await bluetoothProvider.isAvailable();
    if (!isBluetoothOn) {
      MyApp.showSnackBar('Please turn on the Bluetooth');
      AppSettings.openBluetoothSettings();
      return;
    }

    if (Platform.isAndroid) {
      bool isLocationOn = await Geolocator.isLocationServiceEnabled();
      if (!isLocationOn) {
        MyApp.showSnackBar('Please turn on the Bluetooth');
        AppSettings.openLocationSettings();
      }
    }
    // if (status.isDenied) {
    //   AppSettings.openLocationSettings();
    // }

    bluetoothProvider.scan().catchError((error) async {
      print(error);
      // if (error is PlatformException && error.code == 'no_permissions') {
      //   await requestPermission('Bluetooth', 'Location');
      // }
    });

    await showDialog(
      context: context,
      routeSettings: const RouteSettings(name: 'dialog'),
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(CupertinoIcons.clear),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const Expanded(
                child: FindDeviceScreen(),
              )
            ],
          ),
        );
      },
    );
    final crntDevice = bluetoothProvider.currentDevice;
    if (crntDevice == null) {
      return;
    }

    if (authProvider.currentTester != null) {
      final crntState = crntDevice.state;
      final selectedTesterId = authProvider.currentTester!.id;
      crntDevice.crntTesterId = selectedTesterId;
      await routeByCurrentState(crntState, selectedTesterId);
    }
    setAutoRouting(crntDevice);
  }

  setAutoRouting(CleoDevice device) {
    // assert(device.state is IdleState);

    Future<void> listenStateChange() async {
      // debugPrint('context :: MAIN LISTENER TRIGGERED');
      if (!mounted) {
        // debugPrint('not mounted :: remove listner');
        device.removeListener(listenStateChange);
        return;
      }
      if (!device.connected) {
        // debugPrint('device disconnected :: remove listner');
        device.removeListener(listenStateChange);
        return;
      }
      final route = ModalRoute.of(context)!;
      if (!route.isCurrent) {
        // debugPrint('route name ${route.settings.name}');
        // debugPrint(
        //     'route ${route.isFirst} ${route.isActive} ${route.isCurrent} ');
        // debugPrint('not top context');
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentTester == null) {
        debugPrint('tester not selected');
        return;
      }
      final testerId = authProvider.currentTester!.id;
      final crntState = device.state;
      // device.removeListener(listenStateChange);ㅂ
      debugPrint('crntState ====== $crntState');
      await routeByCurrentState(crntState, testerId);
      // device.removeListener(listenStateChange);
    }

    if (autoRouteListener != null) {
      debugPrint('remove old auto router');
      device.removeListener(autoRouteListener);
    }
    device.addListener(listenStateChange);
    autoRouteListener = listenStateChange;
    listenStateChange();
    debugPrint('auto router ready');
  }

  Future<void> routeByCurrentState(CleoState crntState, int testerId) async {
    final isPrepareState = crntState is QrScanState ||
        crntState is QrScanState ||
        crntState is CartridgeInsertState ||
        crntState is CartridgeTubeOpenState ||
        crntState is CartridgeSwabOpenState ||
        crntState is CartridgeSampleGetState ||
        crntState is CartridgeSampleCloseState ||
        crntState is CartridgeSampleMixState ||
        // crntState is CartridgeTubeInsertState ||
        crntState is CloseCoverState;

    if (isPrepareState) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        TestPrepareScreen.routeName,
        (route) => route.isFirst,
      );
    } else if (crntState is IdleState) {
      return;
    } else if (crntState is TestProgressState ||
        crntState is TestCompleteState) {
      final reportId = await DeviceMem.getRunningReportId(testerId);
      if (reportId == null) {
        debugPrint('device is in TestProgress, but related report not found');
        return;
      }
      final report = await SqlReport.getReport(reportId);
      if (report == null) {
        debugPrint('device is in TestProgress, but related report not found');
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => ResultProgressScreen(reportId: report.id!),
        ),
        (route) => route.isFirst,
      );
    }
  }

  List<PopupMenuItem> buildDebugMenu() {
    return [
      PopupMenuItem(
        child: InkWell(
          onTap: () {
            Navigator.of(context)
              ..pop()
              ..push(
                MaterialPageRoute(
                  builder: (ctx) {
                    return const DebugBlueScreen();
                  },
                ),
              );
          },
          child: Row(
            children: const [
              Text('DEBUG'),
            ],
          ),
        ),
      ),
      // PopupMenuItem(
      //   child: InkWell(
      //     onTap: () {
      //       Map testData = {
      //         'id': 7,
      //         'name': 'noti debug',
      //         'macAddress': 'DE:93:13:F6:6B:AE',
      //       };

      //       LocalNotification.sendScheduleMsg(
      //         title: 'Test Complete',
      //         body: 'User1 Test Complete',
      //         id: 1,
      //         payload: jsonEncode(testData),
      //         duration: const Duration(seconds: 3),
      //       );
      //     },
      //     child: Row(
      //       children: const [
      //         Text('noti'),
      //       ],
      //     ),
      //   ),
      // ),
    ];
  }

  buildPopupWidget() {
    return PopupMenuButton(
      onSelected: (selection) {},
      icon: SvgPicture.asset('assets/images/settingBtn.svg', width: 22),
      itemBuilder: (context) {
        return [
          if (MyApp.isDebug) ...buildDebugMenu(),
          PopupMenuItem(
            child: InkWell(
              onLongPress: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'App version',
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                  // Text('1.1.0'),
                  Text(packageInfoVersion),
                  // if (Platform.isAndroid)
                  //   const Text('1.1.0')
                  // else if (Platform.isIOS)
                  //   const Text('1.2'),
                ],
              ),
            ),
          ),
          PopupMenuItem(
            child: InkWell(
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
                        onPressed: () async {
                          final BluetoothProvider bleProvider =
                              Provider.of<BluetoothProvider>(context,
                                  listen: false);
                          await bleProvider.disconnect();
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
              child: Row(
                children: const [
                  Icon(Icons.login_outlined),
                  SizedBox(width: 8),
                  Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          PopupMenuItem(
            child: InkWell(
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
              child: Row(
                children: const [
                  Icon(Icons.check),
                  SizedBox(width: 8),
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          PopupMenuItem(
            child: InkWell(
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
                        onPressed: () async {
                          try {
                            final BluetoothProvider bleProvider =
                                Provider.of<BluetoothProvider>(context,
                                    listen: false);
                            await bleProvider.disconnect();
                            await FirebaseAuth.instance.currentUser!.delete();
                            Navigator.of(context).pop();
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'requires-recent-login') {
                              print(
                                  'The user must reauthenticate before this operation can be executed.');

                              Navigator.of(context).pushReplacementNamed(
                                  DeleteAccountScreen.routeName);
                            }
                          }
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
              child: Row(
                children: const [
                  Icon(Icons.delete_forever_outlined),
                  SizedBox(width: 8),
                  Text(
                    'Delete account',
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];
      },
    );
  }

  checkPermissionAndRequest() async {
    if (Platform.isAndroid) {
      if (asking) {
        return;
      }
      asking = true;

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt ?? 0;

      if (sdkInt >= 31) {
        await checkPermissionAndRequestAndroid31();
      } else {
        await checkPermissionAndRequestAndroidOther();
      }

      asking = false;
      return;
    } else if (Platform.isIOS) {
      const blue = Permission.bluetooth;
      final blueGranted = await blue.isGranted;
      const came = Permission.camera;

      final cameranted = await came.isGranted;

      if (blueGranted && cameranted) {
        return;
      }
      if (showNotice) {
        await popUpPermissionNotice();
        showNotice = false;
      }

      final updated = await blue.request();
      final status = await came.request();

      if (!updated.isGranted) {
        await requestPermission('Bluetooth', 'Nearby devices');
      }
      if (status == PermissionStatus.permanentlyDenied) {
        await requestPermission('QRcode', 'Camera');
      }
    }
    return;
  }

  Future popUpPermissionNotice() {
    return showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (dialogCtx) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: const PermissionNoticeScreen(),
        );
      },
    );
  }

  checkPermissionAndRequestAndroidOther() async {
    const blue = Permission.bluetooth;
    const location = Permission.location;
    const came = Permission.camera;

    final blueGranted = await blue.isGranted;
    final locGranted = await location.isGranted;
    final cameranted = await came.isGranted;

    if (blueGranted && locGranted && cameranted) {
      return;
    }

    if (showNotice) {
      await popUpPermissionNotice();
      showNotice = false;
    }

    if (!blueGranted) {
      final updated = await blue.request();
      final status = await came.request();
      final status2 = await location.request();
      if (!updated.isGranted) {
        await requestPermission('Bluetooth', 'Nearby devices');
      }
      if (status == PermissionStatus.permanentlyDenied) {
        await requestPermission('QRcode', 'Camera');
      }
      if (status2 == PermissionStatus.permanentlyDenied) {
        await requestPermission('bluetooth connect', 'Location');
      }
    }

    // if (!locGranted) {
    //   final updated = await blue.request();
    //   if (!updated.isGranted) {
    //     await requestPermission('Bluetooth', 'Bluetooth');
    //   }
    // }
  }

  checkPermissionAndRequestAndroid31() async {
    // const scan = Permission.bluetoothScan;
    const conn = Permission.bluetoothConnect;
    const came = Permission.camera;
    const loca = Permission.location;
    // final scanGranted = await scan.isGranted;
    final connGranted = await conn.isGranted;
    final cameranted = await came.isGranted;
    final locaGranted = await loca.isGranted;

    if (/* scanGranted && */ connGranted && locaGranted && cameranted) {
      return;
    }

    if (showNotice) {
      await popUpPermissionNotice();
      showNotice = false;
    }

    // if (!scanGranted) {
    //   final updated = await scan.request();
    //   if (!updated.isGranted) {
    //     await requestPermission('Bluetooth', 'Nearby devices');
    //   }
    // }
    if (!connGranted) {
      final updated = await conn.request();
      final status = await came.request();
      final status2 = await loca.request();
      if (!updated.isGranted) {
        await requestPermission('Bluetooth', 'Nearby devices');
      }
      if (status == PermissionStatus.permanentlyDenied) {
        await requestPermission('QRcode', 'Camera');
      }
      if (status2 == PermissionStatus.permanentlyDenied) {
        await requestPermission('bluetooth connect', 'Location');
      }
    }
  }

  Future requestPermission(String functionality, String permission) async {
    const bold = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    const norm = TextStyle(fontSize: 16, color: Colors.black);
    await showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (dialogCtx) {
        return CupertinoAlertDialog(
          title: const Text('Require Permission'),
          content: RichText(
            text: TextSpan(
              style: norm,
              children: [
                const TextSpan(text: '\n'),
                TextSpan(text: permission, style: bold),
                const TextSpan(text: ' permission '),
                const TextSpan(text: ' is essential for the '),
                TextSpan(text: functionality, style: norm),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Go To Settings'),
              onPressed: () async {
                await openAppSettings().then((val) {
                  if (val) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                });
              },
            )
          ],
        );
      },
    );
  }

  void initAutoRouteListener() {
    if (autoRouteListener != null) {
      return;
    }
    final crntDevice = Provider.of<BluetoothProvider>(context).currentDevice;
    if (crntDevice == null) {
      return;
    }
    debugPrint('autoRoute not set -- try setting...');
    setAutoRouting(crntDevice);
  }
}
