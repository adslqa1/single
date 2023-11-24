import 'package:cleo/model/test_report.dart';
import 'package:cleo/screen/common/confirm_button.dart';
import 'package:cleo/screen/common/custom_appbar.dart';
import 'package:cleo/screen/report/detail.dart';
import 'package:cleo/util/sql_helper.dart';
import 'package:flutter/material.dart';

import 'package:cleo/constants.dart' as cons;
import 'package:intl/intl.dart';
import '../../model/test_result.dart';

class ReportListScreen extends StatefulWidget {
  static const routeName = '/reportList';

  const ReportListScreen({Key? key}) : super(key: key);

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  TestReport? _selectedTestReport;

  List testerData = [];

  // List<TestResult> dummy = List.generate(
  //   6,
  //   (index) => TestResult.fromMap({
  //     'id': index,
  //     'userId': index,
  //     'name': 'tester$index',
  //     'birthday': '1991-02-09',
  //     'gender': 0,
  //     'createdAt': '2022-02-24 10:00',
  //     'lotNum': '5A1021',
  //     'exp': '2022-09-09',
  //     'disease': 'COVID-19',
  //   }),
  // ).toList();

  List<TestReport> reportList = [];
  // List<TestReport> reportList = List.generate(
  //   6,
  //   (index) => TestReport.fromMap(
  //     {
  //       'userId': index,
  //       'name': 'tester$index',
  //       'testType': 'COVID-19',
  //       'birthday': '1991-02-09',
  //       'gender': 0,
  //       'macAddress': 'ESDE:ER3E:33ER:AS23',
  //       'expire': '2022-09-09',
  //       'lotNum': '5A1021',
  //       'id': index,
  //       'reportStatus': 2,
  //       'startAt': '2022-03-03 10:00',
  //       'endAt': '2022-03-03 10:30',
  //       'result1': 100,
  //       'result2': 200,
  //       'result3': 300,
  //       'finalResult': 1,
  //     },
  //   ),
  // );

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Test Results',
        useBack: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'To check detailed test results, select the desired data and click VIEW.',
                style: TextStyle(
                  color: Color(0xff717071),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: reportList.length,
                  itemBuilder: (context, index) {
                    TestReport testReport = reportList[index];
                    return userCard(testReport);
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (reportList.isNotEmpty)
                FlatConfirmButton(
                  onPressed: () {
                    if (_selectedTestReport == null) {
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ReportDetailScreen(
                          reportId: _selectedTestReport!.id!,
                          confirmAction: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        settings: const RouteSettings(
                          name: ReportDetailScreen.routeName,
                        ),
                      ),
                    );
                  },
                  label: 'VIEW',
                  reversal: _selectedTestReport != null,
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget userCard(TestReport testReport) {
    final bool isSelected = _selectedTestReport == testReport;
    // -1: Negative 0:Invalid 1: A & B Positive 2: A Positive 3: B Positive
    String testResultString = '';
    Color testResultcolor = const Color(0xff444444);

    if (testReport.reportStatus != ReportStatus.complete) {
      switch (testReport.reportStatus) {
        case ReportStatus.cancel:
          testResultString = 'Canceled';
          testResultcolor = Colors.red;
          break;
        case ReportStatus.running:
          testResultString = 'Running';
          testResultcolor = cons.primary;
          break;
        case ReportStatus.pending:
        default:
          testResultString = 'Pending';
          testResultcolor = const Color(0xff444444);
          break;
      }
    } else {
      switch (testReport.finalResult) {
        case -1:
          testResultString = 'NEGATIVE';
          testResultcolor = const Color(0xff39B54A);
          break;
        case 0:
          testResultString = 'INVALID';
          testResultcolor = const Color(0xffE7B53E);
          break;
        case 1:
          if(testReport.testType == 'COVID-19') {
            testResultString = 'POSITIVE';
            testResultcolor = const Color(0xffC50018);
          }
          else
          {
            testResultString = 'A & B POSITIVE';
            testResultcolor = const Color(0xffC50018);
          }
          break;
        case 2:
          testResultString = 'A POSITIVE';
          testResultcolor = const Color(0xffC50018);
          break;
        case 3:
          testResultString = 'B POSITIVE';
          testResultcolor = const Color(0xffC50018);
          break;
      }
    }

    return InkWell(
      onTap: () {
        setState(() {
          _selectedTestReport = testReport;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
            color: isSelected ? cons.primary : const Color(0xfffffff),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? cons.primary : Color(0xFFB4B4B4),
            )),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : const Color(0xFFB4B4B4),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      testReport.name[0],
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testReport.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatDate(testReport.startAt),
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xff717071),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight, // 오른쪽 정렬
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${testReport.testType} Test',
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xff717071),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      testResultString,
                      style: TextStyle(
                        color: isSelected ? Colors.white : testResultcolor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void loadReports() async {
    final sqlResults = await SqlReport.loadReport();
    final dataList = sqlResults
        .map((raw) => TestReport.fromMap(raw))
        .where((TestReport report) =>
            report.reportStatus != 0 && report.reportStatus != 1)
        .toList();

    dataList.sort((a, b) {
      return b.id!.compareTo(a.id!);
    });

    setState(() {
      reportList = dataList;
    });
  }

  String formatDate(String? date) {
    if (date == null) {
      return '-';
    }
    final local = DateTime.parse(date).toLocal();
    return DateFormat('MM.dd.yyyy HH:mm').format(local);
  }
}
