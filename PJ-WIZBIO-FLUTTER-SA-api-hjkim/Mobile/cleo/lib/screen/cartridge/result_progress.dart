import 'dart:async';
import 'dart:math';

import 'package:cleo/cleo_device/cleo_data.dart';
import 'package:cleo/cleo_device/cleo_device.dart';
import 'package:cleo/cleo_device/cleo_error.dart';
import 'package:cleo/cleo_device/cleo_state.dart';
import 'package:cleo/constants.dart' as cons;
import 'package:cleo/model/test_report.dart';
import 'package:cleo/provider/bluetooth.provider.dart';
import 'package:cleo/screen/cartridge/cartridge_final.dart';
import 'package:cleo/screen/cartridge/test_result.dart';
import 'package:cleo/screen/common/confirm_button.dart';
import 'package:cleo/screen/common/custom_appbar.dart';
import 'package:cleo/util/notification.dart';
import 'package:cleo/util/sql_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../util/fittingDataCalc.dart';
import '../../util/http_info_request.dart';
import 'cartridge_final.dart';

List<Color> genColors(double percent) {
  const startColor2 = Color(0xff83E2E3);
  const startColor1 = Color(0xff486FD6);
  return [
    startColor1,
    startColor2,
  ];
}

int progressInt(int startInt, int endInt, double percent) {
  final value = startInt + ((endInt - startInt) * percent).toInt();
  return max(0, min(value, 255));
}

class ResultProgressScreen extends StatefulWidget {
  static const routeName = '/resultProgress';

  final int reportId;

  const ResultProgressScreen({Key? key, required this.reportId})
      : super(key: key);

  @override
  State<ResultProgressScreen> createState() => _ResultProgressScreenState();
}

class _ResultProgressScreenState extends State<ResultProgressScreen> {
  double _percent = 0;

  Timer? _timer;
  Timer? _tempTimer;

  String _reaminTimeString = '';

  int _lastReportId = -1;
  bool _busy = false;
  bool _collectingData = false;
  int? _reportStatus;

  bool _dialogOpen = false;
  void Function()? deviceListener;

  bool reconnecting = false;
  bool showError = false;

  TestReport? _report;

  late Uri _url = Uri.parse('https://wizdx.com/wizbio/api/v1');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_busy &&
        _lastReportId != widget.reportId &&
        WidgetsBinding.instance != null) {
      _lastReportId = widget.reportId;
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        init(widget.reportId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        askCancelTest(context);
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Test in progress'),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 11),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xff9B9B9C)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 0, 16, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _report!.testType,
                                  style: TextStyle(
                                    fontSize: 24,
                                    height: 1.4,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Image.asset(
                                  'assets/images/covid.png',
                                  width: 35,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 16,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: const Text(
                          'Test Type',
                          style: TextStyle(
                            fontSize: 20,
                            color: cons.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 11),
                      decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xff9B9B9C)),
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            Text(
                              _reaminTimeString,
                              style: const TextStyle(
                                color: cons.primary,
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 16,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: const Text(
                          'Remaining Time',
                          style: TextStyle(
                            fontSize: 20,
                            color: cons.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                CircularPercentIndicator(
                  rotateLinearGradient: false,
                  circularStrokeCap: CircularStrokeCap.round,
                  radius: MediaQuery.of(context).size.width * 0.22,
                  lineWidth: 10.0,
                  percent: _percent,
                  backgroundColor: const Color.fromARGB(255, 231, 231, 231),
                  // backgroundColor: const Color.fromRGBO(62, 223, 251, 0.1),
                  center: Container(
                    margin: const EdgeInsets.all(24),
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: Text(
                        "${(_percent * 100).floor()} %",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.09,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // progressColor: Colors.red,
                  animation: true,
                  animateFromLastPercent: true,
                  linearGradient: LinearGradient(
                    colors: genColors(_percent),
                    begin: Alignment.topRight,
                    end: Alignment.topLeft,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Keep your mobile device\n close to your CLEO ONE\n for Bluetooth connection\n while Test in progress',
                  style: TextStyle(
                    // color: Color(0xffC95520),
                    fontSize: 18,
                  ),
                ),
                if (!_busy && !_collectingData)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => askCancelTest(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 24,
                            ),
                            child: const Text(
                              'CANCEL TEST',
                              style: TextStyle(
                                fontSize: 20,
                                color: Color(0xff717071),
                                decoration: TextDecoration.underline,
                                // decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        // const SizedBox(height: 48),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  init(int reportId) async {
    try {
      // get report
      final report = await getReport(reportId);
      _report = report;
      checkReportState(report);
      await checkDeviceConnection(report).then((_) {
        listenDeviceError();
      });

      startTimer(report);
    } catch (err) {
      showErrorAndGoHome(err.toString());
    } finally {}
  }

  Future<TestReport> getReport(int reportId) async {
    final report = await SqlReport.getReport(reportId);
    if (report == null) {
      throw 'Report not exist';
    }
    return report;
  }

  checkReportState(TestReport report) {
    setState(() {
      _reportStatus = report.reportStatus;
    });
  }

  Future<void> checkDeviceConnection(TestReport report) async {
    CleoDevice device;
    try {
      device = await checkDevice(report.macAddress, report.userId);
    } catch (err) {
      return showErrorAndGoHome(err.toString());
    }

    final isConnected = await waitConnection(device);

    if (!isConnected) {
      await showErrorAndGoHome('Device is NOT connected');
    }
    return;
  }

  listenDeviceError() {
    if (deviceListener != null) {
      return;
    }
    final device =
        Provider.of<BluetoothProvider>(context, listen: false).currentDevice!;

    void listener() {
      debugPrint('context :: RESULT PROGRESS LISTENER WORKING');
      final state = device.state;
      if (!mounted) {
        device.removeListener(listener);
        return;
      }

      // handle custom error
      if (!showError && device.error != null) {
        final error = device.error!;
        if (error is CustomError) {
          showError = true;
          showErrorAndGoHome(error.desc);
          return;
        }
        if (error is CoverTimeoutError) {
          showError = true;
          showErrorAndGoHome(error.desc);
          return;
        }
      } else if (showError && device.error == null) {
        showError = false;
      }

      // handle conn state change
      if (!reconnecting && !device.connected) {
        reconnecting = true;
        showReconnectDialog();
        device.connectAndPair(_report!.userId).catchError((_) {
          if (mounted) {
            device.updateError(ReconnectionFailError(''));
          }
        });
      } else if (reconnecting && device.connected) {
        if (device.error is ReconnectionFailError) {
          device.updateError(null);
        }
        reconnecting = false;
      }

      // if (state is ErrorState) {
      //   device.removeListener(listener);
      //   _timer!.cancel();
      //   cancelTest();
      //   showErrorAndGoHome(state.errorMsg);
      //   return;
      // } else
      if (state is TestCompleteState) {
        deviceListener = null;
        device.removeListener(listener);
        return;
      } else if (device.lastState is! ProgressCoverOpenState &&
          state is ProgressCoverOpenState) {
        if (_dialogOpen) {
          return;
        }
        _dialogOpen = true;
        showDialog(
          context: context,
          routeSettings: const RouteSettings(name: 'cover_dialog'),
          barrierDismissible: false,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: const AlertDialog(
                content: Text('Plese Close the Device Cover'),
              ),
            );
          },
        ).then((_) => _dialogOpen = false);
        return;
      } else if (state is TestProgressState) {
        Navigator.of(context)
            .popUntil((route) => route.settings.name != 'cover_dialog');
        return;
      }
    }

    deviceListener = listener;
    device.addListener(listener);
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
                    'WARNING',
                    style: TextStyle(
                      color: Color(0xffC20018),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Device Disconnected',
                    style: TextStyle(
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
                      onPressed: () async {
                        await crntDevice.state.cancelTest();
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
                  AnimatedBuilder(
                    animation: crntDevice,
                    builder: (context, _) {
                      if (!crntDevice.connected &&
                          crntDevice.error is! ReconnectionFailError) {
                        return const SizedBox(height: 0);
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 24),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.popUntil(
                                context,
                                (route) =>
                                    route.settings.name != 'conn_dialog');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            width: double.infinity,
                            child: const Center(
                              child: Text(
                                'BACK TO TEST',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
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

  void startTimer(TestReport report) {
    // const int durationSec = (CleoDevice.SP_TEST_CYCLE * CleoDevice.SP_TEST_TIME) +
    //     (CleoDevice.TEST_CYCLE * CleoDevice.TEST_TIME); //2023.10.16_CJH
    const int durationSec = 10; // test
    const Duration testDuration = Duration(seconds: durationSec);
    final _startAt = DateTime.parse(report.startAt!);
    final _endTime = _startAt.add(testDuration);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final _now = DateTime.now();
      final passedTime = _now.difference(_startAt);
      final remainTime = _endTime.difference(_now);
      double calcPer = passedTime.inSeconds / testDuration.inSeconds;

      final remainMinutes = remainTime.inMinutes;
      final remainSeconds = remainTime.inSeconds % 60;

      // ---- START :: temp code for demo
      if (report.name == 'test_user' && remainMinutes < 27) {
        _timer?.cancel();
        skipTest();
        return;
      }
      // ---- END :: temp code for demo

      if (calcPer >= 1) {
        _reaminTimeString = '0 Min 0 Seconds';
        setState(() {
          _percent = 1;
        });
        _timer?.cancel();
        handleTimerEnd(report.id!);
        return;
      } else {
        _reaminTimeString = '$remainMinutes minutes $remainSeconds seconds';
        setState(() {
          _percent = calcPer;
        });
      }
    });
  }

  changeReportState(int reportStatus) async {
    final report = await getReport(widget.reportId);
    report.reportStatus = reportStatus;
    await SqlReport.updateReport(report.id!, report);
  }

  cancelTest() async {
    final device =
        Provider.of<BluetoothProvider>(context, listen: false).currentDevice!;
    final state = device.state;
    try {
      assert(state is TestProgressState);
      await (state as TestProgressState).sendCancel();
    } catch (err) {
      print('ignore none progress state');
    }

    cancelNotification();
    final report = await getReport(widget.reportId);
    if (report.reportStatus != ReportStatus.complete) {
      await changeReportState(ReportStatus.cancel);
    }
  }

  Future<void> cancelNotification() async {
    final report = await getReport(widget.reportId);
    final testerId = report.userId;
    LocalNotification.cancelSchdule(testerId);
  }

  askCancelTest(BuildContext context) async {
    return showDialog(
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
                    'Are you sure you want to cancel the test? Once testing is canceled, you cannot use the cartridge and will need a new cartridge.',
                    style: TextStyle(
                      fontSize: 17,
                      // color: Color(0xffCC6116),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: FlatConfirmButton(
                    onPressed: () async {
                      await cancelTest();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    label: 'CANCEL TEST',
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: FlatConfirmButton(
                    onPressed: () => Navigator.of(context).pop(),
                    label: 'BACK TO TEST',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showErrorAndGoHome(String msg) {
    showDialog(
      routeSettings: const RouteSettings(name: 'dialog'),
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
                    msg,
                    style: const TextStyle(
                      color: Color(0xffCC6116),
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: FlatConfirmButton(
                      onPressed: () async {
                        await cancelTest();
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        // Provider.of<BluetoothProvider>(context, listen: false)
                        //     .disconnect();
                      },
                      label: 'CANCEL TEST',
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

  // 20220622 - HyeongJin Kim (SA)
  // Description raw data checkSum logic update
  showErrorAndgoHomeAndRestart(String msg, int reportId) {
    showDialog(
      routeSettings: const RouteSettings(name: 'Test in progress'),
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
                    msg,
                    style: const TextStyle(
                      color: Color(0xffCC6116),
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: FlatConfirmButton(
                      onPressed: () async {
                        handleTimerEnd(reportId);
                        // Navigator.of(context).popUntil((route) =>
                        //     route.settings.name != 'Test in progress');
                        // Provider.of<BluetoothProvider>(context, listen: false)
                        //     .disconnect();
                      },
                      label: 'REQUEST AGAIN',
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: FlatConfirmButton(
                      onPressed: () async {
                        await cancelTest();
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        // Provider.of<BluetoothProvider>(context, listen: false)
                        //     .disconnect();
                      },
                      label: 'CANCEL TEST',
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

  // /20220622 - HyeongJin Kim (SA)
  gotoResultScreen(int reportId) {
    Navigator.of(context)
      ..popUntil((route) => route.isFirst)
      ..push(
        MaterialPageRoute(
          builder: (context) => CartridgeFinalScreen(
            reportId: reportId,
          ),
        ),
      );
    // ..push(
    //   MaterialPageRoute(
    //     builder: (context) => TestResultScreen(
    //       reportId: reportId,
    //       useBack: false,
    //       confirmAction: () {
    //         Navigator.pop(context);
    //       },
    //     ),
    //   ),
    // );
  }

  Future<CleoDevice> checkDevice(String deviceId, int testerId) async {
    final btProvider = Provider.of<BluetoothProvider>(context, listen: false);
    CleoDevice? device = btProvider.currentDevice;

    if (device == null) {
      final popDialog = showReconnectProgress();
      final rawDevice = await btProvider.scanForTarget(deviceId);
      if (rawDevice == null) {
        throw 'Device not connected';
      }
      popDialog();
      device = await btProvider.connect(rawDevice, testerId);
    }

    if (device.device.id.toString() != deviceId) {
      throw 'Device ID not matched';
    }

    return device;
  }

  Future<bool> waitConnection(CleoDevice device) async {
    for (int retry = 0; retry < 5; retry++) {
      if (device.connected) {
        return true;
      }
      await Future.delayed(const Duration(seconds: 5));
    }
    return false;
  }

  void handleTimerEnd(int reportId) async {
    final httpInfoRequest = HttpInfoRequest1();
    final report = await getReport(reportId);
    List<CleoData> collected;
    List infoList;
    switch (report.reportStatus) {
      case ReportStatus.complete:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => TestResultScreen(reportId: reportId),
          ),
          (route) => route.isFirst,
        );
        // MyApp.showSnackBar('Already Completed Test');
        return;
      case ReportStatus.cancel:
      case ReportStatus.pending:
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      case ReportStatus.running:
        break;
    }
    final device = await checkDevice(report.macAddress, report.userId);
    // 20220622 - HyeongJin Kim (SA)
    // Description raw data checkSum logic update
    await httpInfoRequest.setCleoDevice(device);
    showDialog(
      context: context,
      barrierDismissible: false,
      routeSettings: const RouteSettings(name: 'progress_overlay'),
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Checking Data...'),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (await httpInfoRequest.checkCleoData()) {
      collected = await httpInfoRequest.getCleoData();
      infoList = await httpInfoRequest.getInfoList(report);
    } else {
      debugPrint('Data Collect Error'.toString());
      showErrorAndgoHomeAndRestart('Data Collect Error', reportId);
      return;
    }

    device.updateState(TestCompleteState(device, ''));
    // 20220616 - HyeongJin Kim (SA)
    // Description raw data delivery logic update
    await collectDataAndPop(device, reportId, collected);
    // 20220613 - HyeongJin Kim (SA)
    // Description API http post test logic (#LIS)
    try {
      for (var i = 0; i < infoList.length; i++) {
        await httpInfoRequest.postJsonData(infoList[i]);
      }
    } catch (err) {
      debugPrint(err.toString());
      showErrorAndGoHome('Failed to Process the Api Reqeust');
      return;
    }
    // /220613 - HyeongJin Kim (SA)
    // /220616 - HyeongJin Kim (SA)
  }

  // 220616 - HyeongJin Kim (SA)
  collectDataAndPop(
      CleoDevice device, int reportId, List<CleoData> collected) async {
    // List<CleoData> collected -> raw, fitting data 전송을 위해 httpInfoRequest객체 전달
    if (_collectingData) {
      return;
    }
    setState(() {
      _collectingData = true;
    });
    try {
      // showDialog(
      //   context: context,
      //   barrierDismissible: false,
      //   routeSettings: const RouteSettings(name: 'progress_overlay'),
      //   builder: (BuildContext context) {
      //     return WillPopScope(
      //       onWillPop: () async => false,
      //       child: Dialog(
      //         child: Padding(
      //           padding: const EdgeInsets.all(16.0),
      //           child: Column(
      //             mainAxisSize: MainAxisSize.min,
      //             children: const [
      //               CircularProgressIndicator(),
      //               SizedBox(height: 16),
      //               Text('Collecting Data...'),
      //             ],
      //           ),
      //         ),
      //       ),
      //     );
      //   },
      // );
      await saveCollectedData(device, collected, reportId);
    } catch (err) {
      debugPrint(err.toString());
      showErrorAndGoHome('Failed to Process the Result');
      return;
    }
    Navigator.popUntil(
        context, (route) => route.settings.name != 'progress_overlay');
    (device.state as TestCompleteState).sendFinish();
    showCompleteDialog(context, reportId);
  }

  Future<void> saveCollectedData(
      CleoDevice device, List<CleoData> collected, int reportId) async {
    final spData = collected.where((row) => row.type == 'P');
    final scData = collected.where((row) => row.type == 'C');
    // 220722 - HyeongJin Kim (SA)
    // Description raw fittingData calc logic 추가
    var raw1 =
        await changeStringScope(collected.map((row) => row.ch1).toList());
    var raw2 =
        await changeStringScope(collected.map((row) => row.ch2).toList());
    var raw3 =
        await changeStringScope(collected.map((row) => row.ch3).toList());
    var rawTemp = await changeStringScope(
        collected.map((row) => row.celcius).toList()); // 온도 데이터
    var fitting1 = null;
    var fitting2 = null;
    var fitting3 = null;
    var fittingTemp = null;
    var fittingCT = null;

    FittingDataCalc calc = FittingDataCalc();
    List<List<int>> sData = List.generate(3, (i) => []);
    List<List<double>> dData = List.generate(4, (i) => []);
    int mode = 1;

    sData[0] = collected.map((row) => row.ch1).toList();
    sData[1] = collected.map((row) => row.ch2).toList();
    sData[2] = collected.map((row) => row.ch3).toList();
    List<List<double>> fittingData = await calc.pcrDataProcess(
        sData, dData, mode, device.crntCartridge!.ctValue);
    int requiredLength = 80;  //lis 30min = 80
    dData = ensureMinLength(dData, requiredLength);
    // dData[0].addAll(List<double>.filled(10, 0.0));
    // dData[1].addAll(List<double>.filled(10, 0.0));
    // dData[2].addAll(List<double>.filled(10, 0.0));
    if (fittingData.isNotEmpty) {
      fitting1 = await changeStringScope(fittingData[0].toList()); // ch1
      fitting2 = await changeStringScope(fittingData[1].toList()); // ch2
      fitting3 = await changeStringScope(fittingData[2].toList()); // ch3
      fittingTemp = await changeStringScope(
          scData.map((row) => row.celcius).toList()); // 온도 데이터
      fittingCT = await changeStringScope(fittingData[3].toList()); // CT 데이터
    }
    List<double> ctList = fittingData[3].toList();

    double offset1 = calcAvg(spData.map((row) => row.ch1));
    double offset2 = calcAvg(spData.map((row) => row.ch2));
    double offset3 = calcAvg(spData.map((row) => row.ch3));

    int column1 = calcMax(scData.map((row) => row.ch1));
    int column2 = calcMax(scData.map((row) => row.ch2));
    int column3 = calcMax(scData.map((row) => row.ch3));
    // int? val1 = null;
    // int? val2 = null;
    // int? val3 = null;

    final report = await getReport(reportId);
    report.rawData1 = raw1.toString();
    report.rawData2 = raw2.toString();
    report.rawData3 = raw3.toString();
    report.rawDataTemp = rawTemp.toString();
    report.fittingData1 = fitting1.toString();
    report.fittingData2 = fitting2.toString();
    report.fittingData3 = fitting3.toString();
    report.fittingDataTemp = fittingTemp.toString();
    report.fittingDataCt = fittingCT.toString();
    report.endAt = DateTime.now().toString();
    // 220929 - HyeongJin Kim (SA)
    // if (ctList[0].toDouble() > 0.0) {
    //   val1 = (column1 - offset1).round();
    // } else {
    //   report.fittingDataCt = null;
    // }
    // if (ctList[1].toDouble() > 0.0) {
    //   val2 = (column2 - offset2).round();
    // } else {
    //   report.fittingDataCt = null;
    // }
    // if (ctList[2].toDouble() > 0.0) {
    //   val3 = (column3 - offset3).round();
    // } else {
    //   report.fittingDataCt = null;
    // }

    // report.result1 = val1;
    // report.result2 = val2;
    // report.result3 = val3;
    // // 220929 - HyeongJin Kim (SA)
    report.result1 = ctList[0];
    report.result2 = ctList[1];
    report.result3 = ctList[2];

    report.reportStatus = ReportStatus.complete;
    // debugPrint('collected result $val1, $val2, $val3');
    await SqlReport.updateReport(reportId, report);
  }

  Future<StringBuffer> changeStringScope(List list) async {
    // string scope '{}' and ',' add func
    var concatenate = StringBuffer();
    for (var i = 0; list.length > i; i++) {
      if (i == 0) {
        concatenate.write('{');
        concatenate.write(list[i].toString() + ',');
      } else if (i == list.length - 1) {
        concatenate.write(list[i].toString());
        concatenate.write('}');
      } else {
        concatenate.write(list[i].toString() + ',');
      }
    }
    return concatenate;
  }

  List<List<double>> ensureMinLength(List<List<double>> data, int minLength) {
    for (var i = 0; i < data.length; i++) {
      var currentLength = data[i].length;
      if (currentLength < minLength) {
        // 현재 길이가 원하는 길이보다 작다면, 부족한 만큼 0.0을 추가한다.
        var numberOfElementsToAdd = minLength - currentLength;
        data[i].addAll(List<double>.filled(numberOfElementsToAdd, 0.0));
      }
    }
    return data;
  }

  Future<void> showCompleteDialog(BuildContext context, int reportId) async {
    Navigator.of(context).popUntil((route) {
      final routeName = route.settings.name;
      final isDialog = routeName != null && routeName.contains('dialog');
      return !isDialog;
    });
    return await showDialog(
      routeSettings: const RouteSettings(name: 'complete_dialog'),
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          child: StatefulBuilder(
            builder: (context, setState) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    color: Color.fromRGBO(240, 151, 0, 1),
                    size: 130,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'TEST COMPLETED',
                    style: TextStyle(
                      color: const Color(0xffC20018),
                      fontSize: MediaQuery.of(context).size.width * 0.06,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ConfirmButton(
                    onPressed: () {
                      gotoResultScreen(reportId);
                    },
                    label: 'NEXT',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double calcAvg(Iterable<int> numIter) {
    final count = numIter.length;
    final sum = numIter.reduce((value, element) => value + element);
    return sum / count;
  }

  int calcMax(Iterable<int> numIter) {
    return numIter
        .reduce((value, element) => (element > value ? element : value));
  }

  Future<int> getRandomInt(final nowReportId) async {
    int randomInt = Random().nextInt(3) - 1;
    List<Map> sqlResult = await SqlReport.loadReport(
        where: 'id <>? AND name =?',
        whereArgs: [
          nowReportId,
          'test_user',
        ],
        orderBy: 'id desc',
        limit: 1);
    if (sqlResult.isNotEmpty) {
      final report = TestReport.fromMap(sqlResult[0]);
      switch (report.finalResult) {
        case 3:
          randomInt = 2;
          break;
        case 2:
          randomInt = 3;
          break;
        case 1:
          randomInt = 0;
          break;
        case 0:
          randomInt = -1;
          break;
        case -1:
          randomInt = 1;
          break;
      }
    }
    return randomInt;
  }

  void skipTest() async {
    int randomInt = await getRandomInt(widget.reportId);
    final device =
        Provider.of<BluetoothProvider>(context, listen: false).currentDevice;
    device!.updateState(TestCompleteState(device, ''));
    // final cartridge = device.crntCartridge;

    final reportId = widget.reportId;
    final report = await getReport(reportId);
    switch (randomInt) {
      case 3: // B positive
        report.result1 = 0; // -1
        report.result2 = 10; // 1
        report.result3 = 10; // 1
        break;
      case 2: // A positive
        report.result1 = 10; // 1
        report.result2 = 0; // -1
        report.result3 = 10; // 1
        break;
      case 1: // positive
        report.result1 = 10; // 1
        report.result2 = 10; // 1
        report.result3 = 10; // 1
        break;
      case 0: // invalid
        report.result1 = 10; // 1
        report.result2 = 10; // 1
        report.result3 = 0; // -1
        break;
      case -1: // negative
        report.result1 = 0; // -1 //2023.10.16_CJH
        report.result2 = 0; // -1
        report.result3 = 10; // 1
        break;
      default:
        return;
    }
    report.reportStatus = ReportStatus.complete;
    await SqlReport.updateReport(reportId, report);

    Navigator.popUntil(
        context, (route) => route.settings.name != 'progress_overlay');
    await (device.state as TestCompleteState).sendFinish();
    // cancelNotification(); test시에도 push오게 수정 2022-09-06 - SA hjkim
    showCompleteDialog(context, reportId);
  }

  /// show dialog and return Function for pop dialog
  void Function() showReconnectProgress() {
    showDialog(
      context: context,
      barrierDismissible: false,
      routeSettings: const RouteSettings(name: 'wait_dialog'),
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Reconnecting...'),
              ],
            ),
          ),
        );
      },
    );
    void popFunc() {
      Navigator.of(context)
          .popUntil((route) => route.settings.name != 'wait_dialog');
    }

    return popFunc;
  }
}
