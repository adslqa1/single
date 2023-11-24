import 'package:cleo/model/test_report.dart';
import 'package:cleo/screen/common/confirm_button.dart';
// import 'package:cleo/screen/cartridge/result_progress.dart';
import 'package:cleo/screen/common/custom_appbar.dart';
import 'package:cleo/screen/report/report_content.dart';
import 'package:cleo/util/sql_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



import 'package:cleo/util/http_info_request.dart';

class ReportDetailScreen extends StatefulWidget {
  static const routeName = '/reportDetail';

  final Function? confirmAction;
  final bool useBack;
  final int reportId;

  const ReportDetailScreen({
    Key? key,
    required this.reportId,
    this.confirmAction,
    this.useBack = true,
  }) : super(key: key);

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final _controller = ScrollController();
  bool scrollable = false;
  TestReport? _testReport;
  Future wait = Future.value(0);
  late bool _isSended;
  bool isActive = false;
  late Uri _url = Uri.parse('https://wizdx.com/wizbio/api/v1');

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
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      if (!_controller.hasClients) {
        return;
      }
      final _scrollable = _controller.position.maxScrollExtent > 0;
      if (_scrollable != scrollable) {
        setState(() {
          scrollable = _scrollable;
        });
      }
    });
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Test Results',
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // 필요에 따라 패딩 조정
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround, // 버튼들 사이에 공간을 동등하게 배분
                    children: [
                      // 첫 번째 버튼
                      if (_testReport != null) // 리포트가 로드되었는지 확인
                        Expanded(
                          child: FlatConfirmButton(
                            width: MediaQuery.of(context).size.width * 0.35, // 너비 조정
                            label: 'SEND DATA',
                            onPressed: () async {
                              showDialog(
                                context: context,
                                routeSettings: const RouteSettings(name: 'dialog'),
                                builder: (context) => AlertDialog(
                                  content: const Text(
                                      'Are you sure you want to send data?'),
                                  actions: [
                                    TextButton(
                                      child: const Text("CONFIRM"),
                                      onPressed: () async {
                                        if (isActive) return;
                                        setState(() {
                                          isActive = true;
                                        });
                                        //pro
                                        // _report as TestReport;
                                        var msg = 'completed';
                                        final httpInfoRequest2 = HttpInfoRequest2();
                                        final infoList = await httpInfoRequest2
                                            .getInfoList(_testReport!);

                                        // 2023.04.21_OSJ
                                        for (var element in infoList) {
                                          if (await httpInfoRequest2.postJsonData(
                                                  element, _url) ==
                                              'error') {
                                            msg = 'error';
                                            break;
                                          }
                                        }
                                        try {
                                          for (var i = 0; i < infoList.length; i++) {
                                            await httpInfoRequest2.postJsonData(infoList[i], _url);
                                          }
                                        } catch (err) {
                                          debugPrint(err.toString());
                                          // showErrorAndGoHome('Failed to Process the Api Reqeust');
                                          return;
                                        }

                                        if (msg == 'error') {
                                          await showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                    content: Text('Send Fail'),
                                                    actions: [
                                                      TextButton(
                                                        child: const Text("CONFIRM"),
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                      ),
                                                    ],
                                                  ));
                                        } else {
                                          setState(() {
                                            _isSended = true;
                                          });
                                          _testReport!.isSended = 1;
                                          await SqlReport.updateReport(
                                              _testReport!.id!, _testReport!);
                                          await showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                    content: Text('Send Success'),
                                                    actions: [
                                                      TextButton(
                                                        child: const Text("CONFIRM"),
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                      ),
                                              ],
                                          ));
                                        }

                                        setState(() {
                                          isActive = false;
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(width: 16), // 버튼 사이의 간격 조정
                      // 두 번째 버튼
                      Expanded(
                        child: ConfirmButton(
                          label: getLabel(),
                          onPressed: () {
                            if (isScrollEnd()) {
                              if (widget.confirmAction != null) {
                                widget.confirmAction!();
                              }
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
                    ],
                  ),
                ),
              ),



















              // Align(
              //   alignment: Alignment.bottomCenter,
              //   child: Column(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       if (_testReport != null) // 리포트가 로드되었는지 확인
              //         FlatConfirmButton(
              //           // isRadius: true,
              //           // reversal: true,
              //           width: MediaQuery.of(context).size.width * 0.35, // 필요에 따라 너비 조정
              //           label: 'SEND DATA',
              //           onPressed: () async {
              //             showDialog(
              //               context: context,
              //               routeSettings: const RouteSettings(name: 'dialog'),
              //               builder: (context) => AlertDialog(
              //                 content: const Text(
              //                     'Are you sure you want to send data?'),
              //                 actions: [
              //                   TextButton(
              //                     child: const Text("CONFIRM"),
              //                     onPressed: () async {
              //                       if (isActive) return;
              //                       setState(() {
              //                         isActive = true;
              //                       });
              //                       //pro
              //                       // _report as TestReport;
              //                       var msg = 'completed';
              //                       final httpInfoRequest2 = HttpInfoRequest2();
              //                       final infoList = await httpInfoRequest2
              //                           .getInfoList(_testReport!);

              //                       // 2023.04.21_OSJ
              //                       for (var element in infoList) {
              //                         if (await httpInfoRequest2.postJsonData(
              //                                 element, _url) ==
              //                             'error') {
              //                           msg = 'error';
              //                           break;
              //                         }
              //                       }
              //                       try {
              //                         for (var i = 0; i < infoList.length; i++) {
              //                           await httpInfoRequest2.postJsonData(infoList[i], _url);
              //                         }
              //                       } catch (err) {
              //                         debugPrint(err.toString());
              //                         // showErrorAndGoHome('Failed to Process the Api Reqeust');
              //                         return;
              //                       }

              //                       if (msg == 'error') {
              //                         await showDialog(
              //                             context: context,
              //                             builder: (context) => AlertDialog(
              //                                   content: Text('Send Fail'),
              //                                   actions: [
              //                                     TextButton(
              //                                       child: const Text("CONFIRM"),
              //                                       onPressed: () {
              //                                         Navigator.pop(context);
              //                                       },
              //                                     ),
              //                                   ],
              //                                 ));
              //                       } else {
              //                         setState(() {
              //                           _isSended = true;
              //                         });
              //                         _testReport!.isSended = 1;
              //                         await SqlReport.updateReport(
              //                             _testReport!.id!, _testReport!);
              //                         await showDialog(
              //                             context: context,
              //                             builder: (context) => AlertDialog(
              //                                   content: Text('Send Success'),
              //                                   actions: [
              //                                     TextButton(
              //                                       child: const Text("CONFIRM"),
              //                                       onPressed: () {
              //                                         Navigator.pop(context);
              //                                       },
              //                                     ),
              //                             ],
              //                         ));
              //                       }

              //                       setState(() {
              //                         isActive = false;
              //                       });
              //                       Navigator.pop(context);
              //                     },
              //                   ),
              //                 ],
              //               ),
              //             );
                          
              //           },
              //         ),
              //       // ConfirmButton(
              //       //   label: getLabel(),
              //       //   onPressed: () {
              //       //     // ... 기존 onPressed 로직
              //       //   },
              //       // ),
              //     ],
              //   ),
              // ),
              // const SizedBox(height: 32),

              // Align(
              //   alignment: Alignment.bottomCenter,
              //   child: ConfirmButton(
              //     label: getLabel(),
              //     onPressed: () {
              //       if (isScrollEnd()) {
              //         if (widget.confirmAction != null) {
              //           widget.confirmAction!();
              //         }
              //       } else {
              //         final bottomPixel = _controller.position.maxScrollExtent;
              //         _controller
              //             .animateTo(
              //               bottomPixel,
              //               duration: const Duration(milliseconds: 300),
              //               curve: Curves.easeInOut,
              //             )
              //             .then((_) => setState(() {}));
              //       }
              //     },
              //   ),
              // ),






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

  isScrollEnd() {
    if (!_controller.hasClients) {
      return false;
    }
    final scrollHeight = _controller.position.maxScrollExtent;
    final crntPosition = _controller.position.pixels;
    final isBottom = (scrollHeight < 1) || (scrollHeight - crntPosition < 1);

    return isBottom;
  }

  getLabel() {
    // final isResultInvalid =
    //     _testReport?.reportStatus == ReportStatus.complete &&
    //         _testReport?.finalResult == 0;
    // if (isResultInvalid) {
    //   return 'HOME/RETEST';
    // }

    if (!isScrollEnd()) {
      return 'Next';
    }
    return 'CONFIRM';
  }
}
