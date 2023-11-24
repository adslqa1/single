import 'dart:convert';

import 'package:cleo/cleo_device/cartridge_info.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

class DeviceMem {
  static final tempStore = LocalStorage('running_report');
  static final serialStore = LocalStorage('device_serial');

  static Future<void> setDeviceSerial(String macAddr, String serial) async {
    if (!await serialStore.ready) {
      debugPrint('WARN :: device_serial storage is not ready');
      return;
    }
    await serialStore.setItem(macAddr, serial);
  }

  static Future<String> getDeviceSerial(String macAddr) async {
    if (!await serialStore.ready) {
      debugPrint('WARN :: device_serial storage is not ready');
      return '';
    }
    return await serialStore.getItem(macAddr) ?? '';
  }

  static Future<void> setRunningReportId(int userId, int reportId) async {
    if (!await tempStore.ready) {
      debugPrint('WARN :: running_report storage is not ready');
      return;
    }

    await tempStore.setItem('$userId', reportId);
    return;
  }

  static Future<int?> getRunningReportId(int userId) async {
    if (!await tempStore.ready) {
      debugPrint('WARN :: running_report storage is not ready');
      return null;
    }

    return await tempStore.getItem('$userId');
  }

  static Future<void> setDeviceCartridgeInfo(
      String deviceId, CartridgeInfo info) async {
    if (!await tempStore.ready) {
      debugPrint('WARN :: running_report storage is not ready');
      return;
    }

    final json = jsonEncode(info.toJson());
    await tempStore.setItem(deviceId, json);
    return;
  }

  static Future<CartridgeInfo?> getDeviceCartridgeInfo(String deviceId) async {
    if (!await tempStore.ready) {
      debugPrint('WARN :: running_report storage is not ready');
      return null;
    }

    final json = await tempStore.getItem(deviceId);
    if (json == null) {
      return null;
    }
    return CartridgeInfo.fromJson(jsonDecode(json));
  }
}
