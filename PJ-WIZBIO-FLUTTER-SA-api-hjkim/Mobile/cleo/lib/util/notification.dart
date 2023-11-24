import 'dart:convert';

import 'package:cleo/screen/report/noti_handle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../main.dart';

class LocalNotification {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) {
        print(id);
      },
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (payload) async {
        Map json = {};

        try {
          if (payload != null) json = jsonDecode(payload);
        } catch (err) {
          debugPrint(err.toString());
          return;
        }
        final navigatorState = MyApp.naviKey.currentState;

        navigatorState?.pushNamed(
          NotiHandleScreen.routeName,
          arguments: NotiHandleScreenArguments(json),
        );
      },
    );

    // FlutterNativeTimezone.getLocalTimezone();
    // final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    // tz.setLocalLocation(tz.getLocation(timeZoneName!));

    tz.initializeTimeZones();
  }

  static Future sendScheduleMsg({
    required String title,
    required String body,
    required int id, // userId
    duration = const Duration(minutes: 30),
    String? payload,
  }) async {
    await LocalNotification.flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(duration),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  static Future cancelSchdule(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
