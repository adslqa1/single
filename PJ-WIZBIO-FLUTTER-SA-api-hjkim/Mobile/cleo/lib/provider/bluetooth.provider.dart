import 'dart:async';
import 'dart:io';

import 'package:cleo/cleo_device/cleo_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothProvider with ChangeNotifier {
  final blue = FlutterBluePlus.instance;

  late final StreamSubscription isScanningSub;
  bool isScanning = false;

  Map<DeviceIdentifier, BluetoothDevice> connected = {};
  Map<DeviceIdentifier, ScanResult> scanned = {};
  CleoDevice? currentDevice;

  List<DeviceListItem> getDeviceList() {
    final list = <DeviceListItem>[];
    for (final entry in scanned.entries) {
      final id = entry.key;
      final scanResult = entry.value;
      if (connected[id] != null) {
        list.add(DeviceListItem(true, scanResult.device, scanResult));
      } else {
        list.add(DeviceListItem(false, scanResult.device, scanResult));
      }
    }

    for (final entry in connected.entries) {
      final id = entry.key;
      final connectedDevice = entry.value;
      if (scanned[id] == null) {
        debugPrint(
            'not in scanned but in connected -- ${connectedDevice.name}');
        list.add(DeviceListItem(true, connectedDevice, null));
      }
    }

    list.sort((a, b) {
      if (a.connected && !b.connected) {
        return -1;
      }
      if (!a.connected && b.connected) {
        return 1;
      }
      return a.device.id.id.compareTo(b.device.id.id);
    });

    return list;
  }

  BluetoothProvider() {
    isScanningSub = blue.isScanning.listen((_isScanning) {
      isScanning = _isScanning;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    isScanningSub.cancel();
    super.dispose();
  }

  refreshConnected() async {
    connected = {};
    notifyListeners();
    final devList = await blue.connectedDevices;
    for (final device in devList) {
      if (!device.name.toUpperCase().contains('CLEO')) {
        continue;
      }
      // debugPrint('already connected ${device.id} / ${device.name}');
      connected[device.id] = device;
    }
    notifyListeners();
  }

  Future scan({Duration timeout = const Duration(seconds: 5)}) async {
    refreshConnected();
    if (isScanning) {
      return;
    }
    isScanning = true;
    scanned = {};
    notifyListeners();
    final scanSub = blue.scanResults.listen((scans) {
      final _scanned = <DeviceIdentifier, ScanResult>{};
      for (final result in scans) {
        final device = result.device;
        // print('${device.id} ${device.name}');
        if (!device.name.toUpperCase().contains('CLEO')) {
          continue;
        }
        if (connected[device.id] != null) {
          continue;
        }
        if (_scanned[device.id] != null) {
          continue;
        }
        _scanned[device.id] = result;
      }
      scanned = _scanned;
      notifyListeners();
    });
    try {
      await for (final state
          in blue.state.timeout(const Duration(seconds: 10))) {
        if (state == BluetoothState.on) {
          debugPrint('BT Adapter turned ON');
          break;
        }
      }
    } catch (e) {
      debugPrint('Timeout when waiting for BT adapter ON');
    }
    await blue.startScan(timeout: timeout);
    await scanSub.cancel();
    await blue.stopScan();
    refreshConnected();
    notifyListeners();
  }

  Future<BluetoothDevice?> scanForTarget(String deviceId,
      {Duration timeout = const Duration(seconds: 5)}) async {
    final _deviceId = DeviceIdentifier(deviceId);
    await scan(timeout: timeout);
    if (scanned[_deviceId] != null) {
      return scanned[_deviceId]?.device;
    }
    if (connected[_deviceId] != null) {
      return connected[_deviceId];
    }
    return null;
  }

  disconnect() async {
    await currentDevice?.disconnect();
    // currentDevice?.dispose();
    currentDevice = null;
    notifyListeners();
    await refreshConnected();
  }

  printInfo(ScanResult result) async {
    print(result.advertisementData);
  }

  Future<CleoDevice> connect(BluetoothDevice device, int testerId) async {
    // print('connect to ${device.id}');
    if (Platform.isIOS) {
      await currentDevice?.disconnect();
    }
    if (Platform.isAndroid &&
        currentDevice?.connState == BluetoothDeviceState.connected) {
      await currentDevice?.disconnect();
    }
    currentDevice?.dispose();
    final cleoDevice = CleoDevice(device);
    currentDevice = cleoDevice;
    cleoDevice.addListener(notifyListeners);

    await cleoDevice.connectAndPair(testerId);

    notifyListeners();
    await refreshConnected();

    return cleoDevice;
  }

  Future<bool> isAvailable() async {
    bool avail = await blue.isOn && await blue.isAvailable;
    if (avail) {
      return true;
    }
    // wait for 3 seconds just in case;
    await Future.delayed(const Duration(seconds: 3));
    avail = await blue.isOn && await blue.isAvailable;
    return avail;
  }
}

class DeviceListItem {
  final bool connected;
  final BluetoothDevice device;
  final ScanResult? scanInfo;

  DeviceListItem(this.connected, this.device, this.scanInfo);
}
