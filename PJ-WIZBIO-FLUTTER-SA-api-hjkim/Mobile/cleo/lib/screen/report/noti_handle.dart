import 'package:cleo/screen/cartridge/result_progress.dart';
import 'package:flutter/material.dart';

class NotiHandleScreenArguments {
  final Map payload;

  NotiHandleScreenArguments(this.payload);
}

class NotiHandleScreen extends StatefulWidget {
  static const routeName = '/notiHanlde';
  const NotiHandleScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<NotiHandleScreen> createState() => _NotiHandleScreenState();
}

class _NotiHandleScreenState extends State<NotiHandleScreen> {
  bool processing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      processNotification();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: const Scaffold(
        body: Center(child: Text('Loading')),
      ),
    );
  }

  processNotification() async {
    if (processing) {
      return;
    }
    processing = true;
    final args =
        ModalRoute.of(context)!.settings.arguments as NotiHandleScreenArguments;
    print(args.payload);
    final reportId = args.payload['id'];
    if (reportId == null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    } else {
      print('report_id $reportId');
      Navigator.of(context)
        ..popUntil((route) => route.isFirst)
        ..push(
          MaterialPageRoute(
            builder: (context) {
              return ResultProgressScreen(reportId: reportId);
            },
            settings: const RouteSettings(name: ResultProgressScreen.routeName),
          ),
        );
      return;
    }
  }
}
