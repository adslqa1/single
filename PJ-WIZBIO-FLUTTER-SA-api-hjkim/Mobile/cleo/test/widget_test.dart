import 'dart:developer';

import 'package:cleo/main.dart';
import 'package:cleo/provider/bluetooth.provider.dart';
import 'package:cleo/screen/home/find_device.dart';
import 'package:cleo/util/fittingDataCalc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleo/util/bubble.dart';

void main() {
  // var dd = 'dd';
  testWidgets('main', (WidgetTester tester) async {
    // var dd = 'dd';
    // runApp(const MyApp());
    // BluetoothProvider();
    //await tester.pumpWidget(const MyApp());
    // inspect(tester);
    // inspect(tester.elementList(find.text('Disconnected')));
    // tester.firstWidget()
    // tester.pumpAndSettle()
    // await tester.pumpWidget(const BluetoothProvider());
    // var t = find.text('Disconnected');
    // await tester.tap(t);
    // await tester.enterText(find.byType(TextField), 'Disconnect');
    // await tester.enterText(find.byType(TextField), 'Disconnected');
    // expect(find.text('Disconnected'), findsOneWidget);
    // await tester.tap(findsOneWidget);
    // await tester.pump();
    // Verify that our counter starts at 0.
    // expect(find.text('Disconnected'), findsOneWidget);

      int TEST_CYCLE = FittingDataCalc.TOTAL_CYCLE_INDEX; // 2023.09.11_CJH 30=50 25=40
    List<List<int>> arr =
        List.generate(3, (index) => List.generate(TEST_CYCLE, (index) => 0));
      arr[0] = [
  4095,
7925,
9496,
8528,
7552,
7224,
7140,
7084,
7040,
7004,
6980,
6960,
6944,
6932,
6924,
6916,
6912,
6912,
6908,
6904,
6904,
6900,
6900,
6900,
6896,
6896,
6896,
6896,
6896,
6896,
6896,
6896,
6896,
6896,
6900,
6904,
6904,
6908,
6912,
6916,
6916,
6920,
6920,
6924,
6924,
6928,
6928,
6928,
6928,
6928,
6924,
6924,
6924,
6924,
6924,
6924,
6924,
6924,
6924,
6924,
6924,
6924,
6924,
6924,
6924,
6924,
6924,
6924,
6924,
6928,
6928,
6928,
6928,
6928,
6928,
6928,
6928,
6928,
6928,
6932


    ];
    arr[1] = [
  4095,
7925,
11240,
10824,
10712,
10352,
10220,
10148,
10152,
10104,
10092,
10108,
9936,
9932,
9948,
9960,
9976,
9976,
9984,
9992,
9996,
10004,
10012,
10012,
10024,
10012,
10028,
10020,
10020,
10028,
10052,
10048,
10060,
10072,
10076,
10112,
10196,
10372,
10568,
10736,
10864,
10960,
11044,
11124,
11204,
11268,
11320,
11360,
11400,
11436,
11476,
11504,
11532,
11552,
11588,
11608,
11628,
11644,
11668,
11680,
11688,
11696,
11712,
11720,
11724,
11728,
11740,
11740,
11744,
11744,
11752,
11756,
11756,
11760,
11764,
11764,
11768,
11772,
11772,
11772

    ];
    arr[2] = [
     4095,
7925,
11072,
10372,
9984,
9844,
9752,
9788,
9800,
9768,
9524,
9524,
9528,
9544,
9540,
9544,
9564,
9560,
9572,
9580,
9584,
9596,
9604,
9616,
9624,
9636,
9644,
9656,
9684,
9736,
9936,
10104,
10204,
10288,
10388,
10464,
10508,
10548,
10580,
10604,
10624,
10636,
10648,
10664,
10676,
10688,
10696,
10704,
10708,
10712,
10712,
10720,
10724,
10724,
10732,
10740,
10744,
10748,
10760,
10764,
10764,
10760,
10776,
10776,
10776,
10772,
10788,
10792,
10788,
10788,
10804,
10800,
10800,
10800,
10812,
10808,
10808,
10808,
10816,
10812


    ];

    List<List<double>> dData =
        List.generate(4, (index) => List.generate(TEST_CYCLE, (index) => 0.0));

    double start1 = 0;
    double end1 = 0;
    double start2 = 0;
    double end2 = 0;
    double start3 = 0;
    double end3 = 0;

    FittingDataCalc t = FittingDataCalc();
    List<List<double>> result = await t.pcrDataProcess(arr, dData, 0, '100');

    start1 = t.startPointValue1;
    start2 = t.startPointValue2;
    start3 = t.startPointValue3;

    end1 = t.endPointValue1;
    end2 = t.endPointValue2;
    end3 = t.endPointValue3;


    print(result.toString());

    print(start1.toString());
    print(end1.toString());
    print(start2.toString());
    print(end2.toString());
    print(start3.toString());
    print(end3.toString());

    // await tester.pumpWidget(const FindDeviceScreen());
  });
  // testWidgets('find device ...', (WidgetTester tester) async {
  //   await tester.pumpWidget(const FindDeviceScreen());
  // });
}
