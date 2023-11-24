import 'dart:developer';
import 'dart:ui';
import 'dart:io';
import 'dart:async';

import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:cleo/provider/auth.dart';
import 'package:cleo/routes.dart';
import 'package:cleo/screen/auth/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'provider/bluetooth.provider.dart';
import 'screen/home/main.dart';
import 'util/notification.dart';

import 'firebase_options.dart';

// master ver
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      statusBarBrightness:
          Brightness.light, // Dark == white status bar -- for IOS.
    ),
  );
  // 화면 회전 고정
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await LocalNotification.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  static final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  static final naviKey = GlobalKey<NavigatorState>();
  static final appKey = GlobalKey();
  static const isDebug = false;
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

  static showSnackBar(String msg,
      {Duration duration = const Duration(seconds: 4)}) {
    MyApp.scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: duration,
      ),
    );
  }
}

class _MyAppState extends State<MyApp> {
  final _authProvider = AuthProvider();
  final _bluetoothProvider = BluetoothProvider();
  late final Future initWait;
  bool isNeedUpdateAppVersion = false;

  @override
  initState() {
    initWait = Future.wait([
      Firebase.initializeApp(
        name: 'cleo-one',
        options: DefaultFirebaseOptions.currentPlatform,
      ).whenComplete(() {
        _authProvider.init();
        _initialize();
        super.initState();
      }),
      Future.delayed(const Duration(seconds: 3)),
    ]);
    print('init');
  }

  Future<dynamic> _initialize() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    RemoteConfig remoteConfig = RemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      // minimumFetchInterval: const Duration(hours: 1),
      minimumFetchInterval: const Duration(seconds: 1),
    ));
    await remoteConfig.fetch();
    await remoteConfig.fetchAndActivate();

    print(
        'android_min_version: ${remoteConfig.getString("android_min_version")}');
    print(
        'android_latest_version: ${remoteConfig.getString("android_latest_version")}');
    print(
        'ios_latest_version: ${remoteConfig.getString("ios_latest_version")}');
    print('ios_min_version: ${remoteConfig.getString("ios_min_version")}');
    print(
        '${Platform.isAndroid ? 'android' : 'ios'} my device version: ${packageInfo.version}');
    bool isVersionGreaterThan(String newVersion, String currentVersion) {
      List<String> currentV = currentVersion.split(".");
      List<String> newV = newVersion.split(".");
      bool a = false;
      for (var i = 0; i <= 2; i++) {
        a = int.parse(newV[i]) > int.parse(currentV[i]);
        if (int.parse(newV[i]) != int.parse(currentV[i])) break;
      }
      return a;
    }

    isNeedUpdateAppVersion = isVersionGreaterThan(
        remoteConfig.getString(Platform.isAndroid
            ? "android_latest_version"
            : "ios_latest_version"),
        packageInfo.version);
    print('isNeedUpdateAppVersion: ${isNeedUpdateAppVersion}');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: MyApp.isDebug,
      scaffoldMessengerKey: MyApp.scaffoldKey,
      navigatorKey: MyApp.naviKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        backgroundColor: Colors.white,
      ),
      builder: (context, navi) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
          child: FutureBuilder(
            future: initWait,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return MultiProvider(
                  providers: [
                    ChangeNotifierProvider.value(value: _authProvider),
                    ChangeNotifierProvider.value(value: _bluetoothProvider),
                  ],
                  child: navi,
                );
              } else {
                return const SplashScreen();
              }
            },
          ),
        );
      },
      home: Consumer<AuthProvider>(
        builder: (context, AuthProvider authProvider, child) {
          if (isNeedUpdateAppVersion) {
            return Scaffold(body: PopupGotoStore(authProvider: authProvider));
          } else {
            if (authProvider.isLogin) {
              return WillPopScope(
                onWillPop: () => popUpExitConfirm(context),
                child: const MainScreen(),
              );
            } else {
              return const LoginScreen();
            }
          }
        },
      ),
      routes: routes,
    );
  }

  Future<bool> popUpExitConfirm(BuildContext context) async {
    final exitApp = await showDialog<bool>(
      context: context,
      routeSettings: const RouteSettings(name: 'dialog'),
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Exiting the App?'),
        actions: [
          TextButton(
            child: const Text(
              "EXIT",
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () async {
              await Provider.of<BluetoothProvider>(context, listen: false)
                  .currentDevice
                  ?.disconnect();
              Navigator.of(context).pop(true);
            },
          ),
          TextButton(
            child: const Text("CANCEL"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      ),
    );
    return exitApp ?? false;
  }
}

class PopupGotoStore extends StatelessWidget {
  final AuthProvider authProvider;
  const PopupGotoStore({Key? key, required this.authProvider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () => showAlert(context));
    if (authProvider.isLogin) {
      return WillPopScope(
        onWillPop: () => popUpExitConfirm(context),
        child: const MainScreen(),
      );
    } else {
      return const LoginScreen();
    }
  }

  void showAlert(BuildContext context) {
    var appPackageName = 'com.app.cleo';
    var appAppleId = '1615348718';
    final Uri _androidMarkgetUrl =
        Uri.parse("market://details?id=" + appPackageName);
    // ios url check requried
    final Uri _iosStoreUrl =
        // Uri.parse('itms-apps://itunes.com/apps/cleo-one');
        Uri.parse('https://apps.apple.com/app/id' + appAppleId);
    final Uri _androidUrl = Uri.parse(
        "https://play.google.com/store/apps/details?id=" + appPackageName);
    final Uri _iosUrl =
        Uri.parse('https://apps.apple.com/us/app/cleo-one/id1615348718');
    Future<void> _launchUrl() async {
      try {
        if (await canLaunchUrl(
            Platform.isAndroid ? _androidMarkgetUrl : _iosStoreUrl)) {
          await launchUrl(
              Platform.isAndroid ? _androidMarkgetUrl : _iosStoreUrl,
              mode: LaunchMode.externalApplication);
        } else {
          // safari 에서 url 접근 안될시 설정 - 사파리 - 데스크탑 웹사이트 요청 허용으로 변경해줘야함
          await launchUrl(Platform.isAndroid ? _androidUrl : _iosUrl,
              mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        // market 설치 안되어있으면 인터넷으로 이동
        await launchUrl(Platform.isAndroid ? _androidUrl : _iosUrl,
            mode: LaunchMode.externalApplication);
      }
    }

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content:
                  const Text('You need to update \nto the latest features.'),
              actions: [
                TextButton(
                  onPressed: _launchUrl,
                  child: const Text(
                    "GO TO UPDATE",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  child: const Text("CANCEL"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ));
  }

  Future<bool> popUpExitConfirm(BuildContext context) async {
    final exitApp = await showDialog<bool>(
      context: context,
      routeSettings: const RouteSettings(name: 'dialog'),
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Exiting the App?'),
        actions: [
          TextButton(
            child: const Text(
              "EXIT",
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () async {
              await Provider.of<BluetoothProvider>(context, listen: false)
                  .currentDevice
                  ?.disconnect();
              Navigator.of(context).pop(true);
            },
          ),
          TextButton(
            child: const Text("CANCEL"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      ),
    );
    return exitApp ?? false;
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;

  Color color = const Color(0xff717071);

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    animation =
        ColorTween(begin: const Color(0xff717071), end: const Color(0xff5588F4))
            .animate(controller);

    animation.addListener(() {
      setState(() {
        color = animation.value;
      });
    });

    controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 10),
                              child: Text(
                                'CLEO',
                                style: TextStyle(
                                  color: const Color(0xff717071),
                                  fontSize: size.width * 0.12,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Text(
                                '™',
                                style: TextStyle(
                                  color: const Color(0xff717071),
                                  fontSize: size.width * 0.04,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'O',
                          style: TextStyle(
                            color: color,
                            fontSize: size.width * 0.12,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'NE',
                          style: TextStyle(
                            color: const Color(0xff717071),
                            fontSize: size.width * 0.12,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                    // child: SvgPicture.asset(
                    //   'assets/images/splash.svg',
                    //   width: size.width * 0.5,
                    // ),
                  ),
                ),
                const Text(
                  '© 2022 Wizbiosolutions Inc. All right reserved.',
                  style: TextStyle(color: Color(0xff717071)),
                ),
                const Text(
                  'CLEO™ is a trademark of Wizbiosolutions.',
                  style: TextStyle(color: Color(0xff717071)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
