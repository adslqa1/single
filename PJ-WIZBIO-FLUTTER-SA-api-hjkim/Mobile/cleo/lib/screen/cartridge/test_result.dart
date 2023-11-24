import 'package:cleo/model/test_report.dart';
import 'package:cleo/screen/common/confirm_button.dart';
// import 'package:cleo/screen/cartridge/result_progress.dart';
import 'package:cleo/screen/common/custom_appbar.dart';
import 'package:cleo/screen/report/report_content.dart';
import 'package:cleo/util/sql_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TestResultScreen extends StatefulWidget {
  static const routeName = '/testResult';

  final Function? confirmAction;
  final bool useBack;
  final int reportId;

  const TestResultScreen({
    Key? key,
    required this.reportId,
    this.confirmAction,
    this.useBack = true,
  }) : super(key: key);

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen> {
  final _controller = ScrollController();
  bool scrollable = false;
  TestReport? _testReport;
  Future wait = Future.value(0);

  @override
  void initState() {
    super.initState();
    wait = init();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    checkScrollableState();
    // final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Test Report',
        useBack: widget.useBack,
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _controller,
                  child: FutureBuilder(
                    future: wait,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(
                          child: CupertinoActivityIndicator(),
                        );
                      }
                      if (snapshot.data == false || _testReport == null) {
                        return const Center(
                          child: Text(
                            'No such data',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        );
                      }
                      return ReportDetailView(
                        key: Key('${widget.reportId}}'),
                        testReport: _testReport!,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // ElevatedButton(
              //   onPressed: () async {
              //     Navigator.of(context)
              //         .push(MaterialPageRoute(builder: (ctx) {
              //       return ResultProgressScreen(reportId: _testReport!.id!);
              //     }));
              //   },
              //   child: Text(
              //     'View Progress',
              //     style: TextStyle(fontSize: 18),
              //   ),
              // ),
              Align(
                alignment: Alignment.bottomCenter,
                child: FlatConfirmButton(
                  label: getLabel(),
                  onPressed: () {
                    if (isScrollEnd()) {
                      Navigator.pop(context);
                    } else {
                      final bottomPixel = _controller.position.maxScrollExtent;
                      _controller
                          .animateTo(
                            bottomPixel,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                          .then((_) => setState(() {}));
                    }
                  },
                ),
              ),
              const SizedBox(height: 16)
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> init() async {
    List<Map<String, dynamic>> sqlResult = await SqlReport.loadReport(
      where: 'id =?',
      whereArgs: [
        widget.reportId,
      ],
    );
    if (sqlResult.isNotEmpty) {
      final report = TestReport.fromMap(sqlResult[0]);

      setState(() {
        _testReport = report;
      });
      return true;
    }

    return false;
  }

  bool isScrollEnd() {
    if (!_controller.hasClients) {
      return true;
    }
    final scrollHeight = _controller.position.maxScrollExtent;
    final crntPosition = _controller.position.pixels;
    final isBottom = (scrollHeight < 1) || (scrollHeight - crntPosition < 1);
    return isBottom;
  }

  getLabel() {
    final isResultInvalid =
        _testReport?.reportStatus == ReportStatus.complete &&
            _testReport?.finalResult == 0;
    if (isResultInvalid) {
      return 'HOME/RETEST';
    }

    if (!isScrollEnd()) {
      return 'NEXT';
    }
    return 'HOME';
  }

  void checkScrollableState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      if (!_controller.hasClients) {
        if (scrollable) {
          setState(() {
            scrollable = false;
          });
        }
        return;
      }

      final _scrollable = _controller.position.maxScrollExtent > 0;
      if (_scrollable != scrollable) {
        setState(() {
          scrollable = _scrollable;
        });
      }
    });
  }
}
