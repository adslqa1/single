import 'dart:async';

import 'package:cleo/cleo_device/cleo_device.dart';
import 'package:cleo/cleo_device/cleo_state.dart';
import 'package:cleo/provider/bluetooth.provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DebugBlueScreen extends StatefulWidget {
  const DebugBlueScreen({Key? key}) : super(key: key);

  @override
  State<DebugBlueScreen> createState() => _DebugBlueScreenState();
}

class _DebugBlueScreenState extends State<DebugBlueScreen> {
  final textControl = TextEditingController();
  final scrollControl = ScrollController();
  double lastMax = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Consumer<BluetoothProvider>(
        builder: (context, provider, child) {
          if (provider.currentDevice == null) {
            return const Text('device not connected');
          }
          return ChangeNotifierProvider<CleoDevice>.value(
            value: provider.currentDevice!,
            child: Consumer<CleoDevice>(
              builder: (context, deviceControl, child) {
                Future.delayed(const Duration(milliseconds: 500), updateScroll);
                return Column(
                  children: [
                    Wrap(
                      direction: Axis.horizontal,
                      children: [
                        buildSendButton('연결', 'C,P,1001', deviceControl),
                        buildSendButton('연결해제', 'C,D', deviceControl),
                        buildSendButton(
                          '유저',
                          'C,N,1001',
                          deviceControl,
                          UserSelectState(deviceControl, ''),
                        ),
                        buildSendButton('중단', 'P', deviceControl),
                        buildSendButton(
                          '조건설정',
                          'E,S,61,61,1000,100,800,1700,60,1300,10,30',
                          deviceControl,
                          QrScanState(deviceControl, ''),
                        ),
                        buildSendButton('카트리지 확인', 'T,N,C,P', deviceControl),
                        buildSendButton('튜브 장착', 'C,N,1001', deviceControl),
                        buildSendButton('뚜껑닫힘 확인', 'T,N,L,P', deviceControl),
                        buildSendButton('용해 체크', 'S,P,0001', deviceControl),
                        buildSendButton('형광 측정', 'S,C,0001', deviceControl),
                        buildSendButton('수신 확인', 'T,N,L,0001,P', deviceControl),
                        buildSendButton('Back', 'B', deviceControl),
                        Container(
                          margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                          child: ElevatedButton(
                            onPressed: () => actionCollectData(deviceControl),
                            child: Text('전체결과 호출'),
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: textControl,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'msg',
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            sendCommand(context, deviceControl);
                          },
                          child: const Text('send'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            deviceControl.clearLog();
                          },
                          child: const Text('clear log'),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.grey,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: Container(
                          color: Colors.white,
                          child: ListView.builder(
                            controller: scrollControl,
                            itemCount: deviceControl.log.length,
                            itemBuilder: (context, idx) {
                              final row = deviceControl.log[idx];
                              if (row.received) {
                                return Text(
                                  row.toString(),
                                  style: const TextStyle(color: Colors.red),
                                );
                              } else {
                                return Text(
                                  row.toString(),
                                  style: TextStyle(color: Colors.blue[900]),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  updateScroll() {
    if (scrollControl.hasClients) {
      final crntMax = scrollControl.position.maxScrollExtent;
      if (crntMax != lastMax) {
        scrollControl.animateTo(crntMax,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
        lastMax = crntMax;
      }
    }
  }

  Widget buildSendButton(String label, String str, CleoDevice control,
      [CleoState? forceState]) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: ElevatedButton(
        onPressed: () {
          if (forceState != null) {
            control.updateState(forceState);
          }
          control.sendMsg(str, debug: false);
        },
        child: Text(label),
      ),
    );
  }

  void sendCommand(BuildContext context, CleoDevice deviceControl) {
    final cmd = textControl.text.trim();
    deviceControl.sendMsg(cmd, debug: true);
  }

  actionCollectData(CleoDevice deviceControl) {
    deviceControl.collectData();
  }
}
