// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:math';

// import 'package:cleo/model/tester.dart';
import 'package:cleo/cleo_device/cartridge_info.dart';
import 'package:cleo/cleo_device/cleo_data.dart';
import 'package:cleo/model/test_report.dart';
import 'package:cleo/util/device_mem.dart';
import 'package:cleo/util/sql_helper.dart';
import 'package:crclib/catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'cleo_error.dart';
import 'cleo_state.dart';

List<List<T>> chunkArray<T>(List<T> src, int length) {
  final List<List<T>> chunks = [];
  for (int i = 0; i < src.length; i += length) {
    final end = min<int>(src.length, i + length);
    chunks.add(src.sublist(i, end));
  }
  return chunks;
}

class CleoDevice with ChangeNotifier {
  static const SP_TEST_CYCLE = 30;
  static const SP_TEST_TIME = 10; // 2023.10.12_CJH
  static const TEST_CYCLE = 50; // 2023.09.11_CJH 30=50 25=40
  static const TEST_TIME = 30; // 2023.10.12_CJH
  static const TEST_MIN = ((SP_TEST_CYCLE * SP_TEST_TIME) + (TEST_CYCLE * TEST_TIME)) / 60; // 2023.10.12_CJH

  static final EOL = String.fromCharCode(0x0D);
  static final uartUuid = Guid('6E400001-B5A3-F393-E0A9-E50E24DCCA9E');
  static final txUuid = Guid('6E400002-B5A3-F393-E0A9-E50E24DCCA9E');
  static final rxUuid = Guid('6E400003-B5A3-F393-E0A9-E50E24DCCA9E');
  static final clientDescriptor = Guid('00002902-0000-1000-8000-00805f9b34fb');

  final BluetoothDevice device;

  Map<Guid, BluetoothService> _services = {};
  Map<Guid, BluetoothCharacteristic> _characteristics = {};
  Map<Guid, BluetoothDescriptor> _descriptors = {};

  BluetoothService? _bleService;

  BluetoothDeviceState connState = BluetoothDeviceState.disconnected;

  StreamSubscription<BluetoothDeviceState>? connSub;
  StreamSubscription<List<int>>? msgSub;

  late CleoState state;
  CleoState? lastState;
  CleoError? error;

  CartridgeInfo? crntCartridge;
  TestReport? crntReport;
  int? crntTesterId;
  int nakCount = 0;
  List<int> tempData = [];
  bool waitPair = true;

  List<LogRow> log = [];
  String _concatMessage = '';

  String serial = '';

  bool disposed = false;

  bool get connected =>
      (connState == BluetoothDeviceState.connected) && !waitPair;
  bool get hasError => error != null;

  CleoDevice(this.device) {
    state = IdleState(this, '');
  }

  get shortId {
    final deviceId = device.id.toString();
    return deviceId.substring(deviceId.length - 8);
  }

  Future<void> connectAndPair(int testerId) async {
    serial = await DeviceMem.getDeviceSerial(device.id.toString());
    crntCartridge =
        await DeviceMem.getDeviceCartridgeInfo(device.id.toString());
    try {
      await device.connect(autoConnect: false);
    } on PlatformException catch (err) {
      if (!['already_connected', 'connect'].contains(err.code.trim())) {
        debugPrint('${err.code} :: ${err.message}');
        rethrow;
      }
      debugPrint(err.code);
    } catch (err) {
      rethrow;
    }
    await Future.delayed(const Duration(milliseconds: 250), () {});
    await _listenConnection();
    await _findServices();
    await Future.delayed(const Duration(milliseconds: 250), () {});
    final _rxChar = _getChar(_bleService!, rxUuid);
    try {
      await _rxChar.setNotifyValue(true);
    } catch (err) {
      debugPrint('failed to set notify CCCD');
    }
    await Future.delayed(const Duration(milliseconds: 250), () {});
    await _listenMessage();
    await Future.delayed(const Duration(milliseconds: 250), () {});

    final pass = await pairUser(testerId);
    if (!pass) {
      throw 'connection failed';
    }
    return;
  }

  @override
  void dispose() {
    connSub?.cancel();
    msgSub?.cancel();
    disposed = true;
    super.dispose();
  }

  Future<bool> pairUser(int testerId) async {
    crntTesterId = testerId;
    final _lastSent = 'C,P,$testerId';
    state.lastSent = _lastSent;
    await Future.delayed(const Duration(milliseconds: 1500), () {});
    final isPaired = waitPairing();
    await sendMsg(_lastSent);
    if (!(await isPaired)) {
      await Future.delayed(const Duration(milliseconds: 1000), () {});
      await sendMsg(_lastSent);
    }
    return await isPaired;
  }

  Future<bool> waitPairing() async {
    const _SECONDS = 6;
    for (int i = 0; i < _SECONDS * 10; i++) {
      await Future.delayed(const Duration(milliseconds: 100), () {});
      if (connected) {
        return true;
      }
    }
    return false;
  }

  Future<void> sendMsg(String msg,
      {bool debug = false,
      bool retry = true,
      bool resend = false,
      bool nak = false}) async {
    final txChar = _getChar(_bleService!, txUuid);
    var byteMsg, crc16, log;
    String msgToSend;
    if (nak == true) {
      final List<int> byteNak = [21, 44, 67, 70, 67, 49, 13];
      final text = String.fromCharCodes(byteNak);
      msg = text.trim();
      msgToSend = msg.endsWith('\r') ? msg : msg + '\r';
      // log = LogRow(false, msgToSend, debug ? 'Debug' : state.name, serial);
      byteMsg = chunkArray<int>(byteNak, 20);
    } else if (resend == true) {
      msg = msg.trim();
      msgToSend = msg.endsWith('\r') ? msg : msg + '\r';
      log = LogRow(false, msgToSend, debug ? 'Debug' : state.name, serial);
      byteMsg = chunkArray<int>(msgToSend.codeUnits, 20);
    } else {
      crc16 = Crc16()
          .convert(utf8.encode(msg))
          .toRadixString(16)
          .padLeft(4, '0')
          .toUpperCase();
      msg += ',' + crc16;
      msg = msg.trim();
      msgToSend = msg.endsWith('\r') ? msg : msg + '\r';
      log = LogRow(false, msgToSend, debug ? 'Debug' : state.name, serial);
      pushLog(log);
      byteMsg = chunkArray<int>(msgToSend.codeUnits, 20);
    }
    try {
      for (final packet in byteMsg) {
        await txChar.write(packet, withoutResponse: false);
      }
    } catch (err) {
      debugPrint('$err');
      if (retry) {
        return Future.delayed(const Duration(seconds: 1), () {
          return sendMsg(msg, retry: false);
        });
      } else {
        debugPrint(err.toString());
      }
    }
    debugPrint(log.toString());
    // MyApp.showSnackBar(log, duration: const Duration(seconds: 1));
  }

  void updateState(CleoState newState) {
    lastState = state;
    state = newState;
    notifyListeners();
  }

  setCartridge(CartridgeInfo info) {
    crntCartridge = info;
    notifyListeners();
  }

  // startTest() {
  //   assert(state is IdleState);
  //   lastState = state;
  //   state = QrScanState(this, '')..sendSetting();
  // }

  Future<void> _listenConnection() async {
    await connSub?.cancel();
    connSub = device.state.listen((newConnState) {
      if (disposed) {
        return;
      }
      final log =
          'CONNSTATE CHANGE!!!!!:::::: ----${device.name} $connState > $newConnState';
      debugPrint(log);
      connState = newConnState;
      notifyListeners();
    });
  }

  Future<void> _listenMessage() async {
    print('nakCount ================> ' + nakCount.toString());
    await msgSub?.cancel();
    msgSub = null;
    final rxChar = _getChar(_bleService!, rxUuid);
    StreamSubscription<List<int>>? _sub;
    _sub = rxChar.value.listen((data) {
      if (disposed) {
        _sub?.cancel();
        return;
      }
      if (data.last != 13) {
        tempData += data;
      } else {
        tempData += data;
        data = tempData;
        tempData = [];
        final msg = String.fromCharCodes(data);
        final trimmed =
            msg.substring(0, msg.lastIndexOf(',')).trim(); // protocol
        final wordToChar =
            msg.substring(msg.lastIndexOf(',') + 1).trim(); // hexcode
        final crc16 = Crc16()
            .convert(utf8.encode(trimmed))
            .toRadixString(16)
            .padLeft(4, '0')
            .toUpperCase(); // crc16 검사 진행
        if (crc16 != wordToChar) {
          Future.delayed(const Duration(seconds: 1), () {
            sendMsg('NAK', nak: true);
          });
          nakCount++;
        } else {
          // nakCount = 0;
        }
        if (wordToChar == 'CFC1') {
          // NAK를 받았을때 이전에 보낸 프로토콜 재전송
          // log.lastWhere((element) => element.received == false).log;
          final reSendLog =
              log.lastWhere((element) => element.received == false).log;
          // sendMsg(reSendLog, resend: true);
          nakCount++;
        } else {
          // nakCount = 0;
        }
        _handleMessage(msg);
      }
    });
    msgSub = _sub;
    notifyListeners();
  }

  void _handleMessage(String msg) {
    _concatMessage += msg;
    if (_concatMessage.contains(EOL)) {
      final msgArr = _concatMessage.split(EOL);
      _concatMessage = msgArr.last;
      final rest = msgArr.sublist(0, msgArr.length - 1);
      for (final msg in rest) {
        // final trimmed = msg.trim();
        // print('trimmed =====> ' + trimmed);
        final trimmed =
            msg.substring(0, msg.lastIndexOf(',')).trim(); // protocol
        final newState = state.handleDeviceMsg(trimmed);
        if (newState != state) {
          lastState = state;
          state = newState;
          notifyListeners();
        }
        final log =
            LogRow(true, msg, state.name, serial = serial, lastState?.name);
        pushLog(log);
        // MyApp.showSnackBar(log, duration: const Duration(seconds: 1));
        debugPrint(log.toString());
      }
    }
  }

  _findServices() async {
    final serviceList = await device.discoverServices();
    _services = {};
    _characteristics = {};
    _descriptors = {};
    for (final sv in serviceList) {
      _services[sv.uuid] = sv;
      debugPrint('SERVICE: ${sv.uuid}');
      if (sv.uuid == uartUuid) {
        _bleService = sv;
        for (final char in sv.characteristics) {
          final charUUID = char.uuid;
          _characteristics[charUUID] = char;
          debugPrint(' ㄴCHARRR : $charUUID');
          if (char.uuid == rxUuid) {
            for (final desc in char.descriptors) {
              _descriptors[desc.uuid] = desc;
              debugPrint('   ㄴDESCRRR: ${desc.uuid}');
            }
          }
          if (char.uuid == txUuid) {
            for (final desc in char.descriptors) {
              _descriptors[desc.uuid] = desc;
              debugPrint('    DESCRRR: ${desc.uuid}');
            }
          }
        }
        return sv;
      }
    }
    throw 'BLE Service Not Found';
  }

  BluetoothCharacteristic _getChar(BluetoothService service, Guid charUuid) {
    final list = service.characteristics.where((char) => char.uuid == charUuid);
    assert(list.isNotEmpty);
    return list.first;
  }

  disconnect() async {
    await state.disconnectUser();
    await connSub?.cancel();
    await msgSub?.cancel();
    await device.disconnect();
  }

  clearLog() {
    log = [];
    notifyListeners();
  }

  pushLog(LogRow row) {
    log.add(row);
    if (log.length > 200) {
      log = log.sublist(1);
    }
    notifyListeners();
  }

  Future<List<CleoData>> collectData() async {
    final collected = <CleoData>[];
    await for (final row in streamCollectSP()) {
      collected.add(row);
    }
    await for (final row in streamCollectSC()) {
      collected.add(row);
    }
    return collected;
  }

  Stream<CleoData> streamCollectSP(
      {Duration timeout = const Duration(seconds: 60)}) async* {
    // for (int num = 1; num <= SP_TEST_CYCLE; num++) {
    for (int num = 1; num <= int.parse(crntCartridge!.preTestCycle); num++) {
      final cycle = num.toString().padLeft(4, '0');
      final line = await _getRowData('S,P,$cycle', timeout: timeout);
      final data = CleoData.fromMsg(line);
      yield data;
    }
  }

  Stream<CleoData> streamCollectSC(
      {Duration timeout = const Duration(seconds: 60)}) async* {
    // for (int num = 1; num <= TEST_CYCLE; num++) {
    for (int num = 1; num <= int.parse(crntCartridge!.afterTestCycle); num++) {
      final cycle = num.toString().padLeft(4, '0');
      final line = await _getRowData('S,C,$cycle', timeout: timeout);
      final data = CleoData.fromMsg(line);
      yield data;
    }
  }

  _getRowData(String header,
      {Duration timeout = const Duration(seconds: 60)}) async {
    final completer = Completer();
    var rxChar = _getChar(_bleService!, rxUuid);
    String _line = '';
    StreamSubscription? _msgSub;
    _msgSub = rxChar.value.listen((data) {
      if (disposed) {
        _msgSub?.cancel();
        return;
      }
      final msg = String.fromCharCodes(data);
      _line += msg;
      if (_line.contains(EOL)) {
        final msgArr = _line.split(EOL);
        assert(msgArr.length == 2);
        _line = msgArr.last;
        final msg = msgArr.first;
        if (msg.startsWith(header)) {
          _msgSub?.cancel();
          if (!completer.isCompleted) {
            completer.complete(msg);
          }
        }
      }
    });
    sendMsg(header);
    Future.delayed(timeout, () {
      _msgSub?.cancel();
      if (!completer.isCompleted) {
        completer.completeError('$header timeout');
      }
    });
    return completer.future;
  }

  void updateError(CleoError? error) {
    this.error = error;
    notifyListeners();
  }

  syncState() {
    sendMsg('C,P,$crntTesterId');
  }

  loadReportById(int reportId) async {
    List<Map<String, dynamic>> sqlResult = await SqlReport.loadReport(
      where: 'id =?',
      whereArgs: [
        reportId,
      ],
    );
    if (sqlResult.isNotEmpty) {
      final report = TestReport.fromMap(sqlResult[0]);
      crntReport = report;
    }
    return;
  }

  loadInProgressReportOfTester(int testerId) async {
    List<Map<String, dynamic>> sqlResult = await SqlReport.loadReport(
      where: 'userId =?',
      whereArgs: [
        testerId,
      ],
    );
    if (sqlResult.isNotEmpty) {
      final report = TestReport.fromMap(sqlResult[0]);
      crntReport = report;
    }
    return;
  }
}

class LogRow {
  final bool received;
  final String log;
  final String state;
  final String? lastState;
  final String? hexCode;

  LogRow(this.received, this.log, this.state, [this.lastState, this.hexCode]);

  @override
  String toString() {
    if (received) {
      return 'RECIEVE <<< $log ($lastState => $state) $hexCode';
    } else {
      return 'SENT    >>> $log @ $state';
    }
  }
}
