import 'dart:developer';

import 'package:cleo/constants.dart' as cons;
import 'package:cleo/model/test_report.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResultDescription {
  static String positive1(String testType, String virusName) =>
      '• $virusName RNA was detected in your sample.\n\n• It is very likely that you currently have a $testType virus infection.\n\n• There is a small chance that this test can give a positive result that is incorrect (a false positive).';
  static String positive2(String testType, String virusName) =>
      '• $virusName RNA was detected in your sample.\n\n• It is very likely that you currently have a $testType virus infection.\n\n• There is a small chance that this test can give a positive result that is incorrect (a false positive).';
  static String positive3(String testType, String virusName) =>
      '• $virusName RNA was detected in your sample.\n\n• It is very likely that you currently have a $testType virus infection.\n\n• There is a small chance that this test can give a positive result that is incorrect (a false positive).';



  // static const positive2 =
  //     '• Self-isolate per CDC recommendations to stop spreading the virus to others.\n\n• Consult your healthcare provider as soon as possible.\n\n• If you do not have any symptoms, particularly if you live in an area with low numbers of COVID-19 infections and have had no exposure to anyone diagnosed with COVID-19, additional testing to confirm your result may be required.\n\nA false positive can be given. Clinical correlation with past medical history and additional diagnostic information is necessary to confirm infection status. Hence your healthcare provider will work with you to determine how best to care for you based on test results along with medical history and your symptoms. Positive results do not rule out co-infection with other pathogens.';

  static String negative(String testType, String virusName) =>
      '• The CLEO $testType test did not detect the $virusName that causes $testType in your sample.\n\n• There is still a chance that the test may give a negative result that is incorrect (a false negative) in some people with $testType.';
  static const negative2 =
      '• If you have symptoms and your symptoms persist or become more severe, seek help from a healthcare professional.\n\n• Regardless of the test result, it is important while you are sick you should practice social distancing and good hygiene.';

  static String invalid(String testType, String virusName) =>
      '• The CLEO ONE system is unable to provide a result.\n\n• Common reasons for getting an invalid result are because you did not collect enough sample, the sample was not handled properly, or there was a processing error with the test cartridge.';
  static const invalid2 =
      '• Retest using a new test cartridge, sample tube, and swab. Carefully read the Quick Reference Instructions and Instructions for Use before retesting.';
}

class ReportDetailView extends StatelessWidget {
  final TestReport testReport;

  const ReportDetailView({
    Key? key,
    required this.testReport,
  }) : super(key: key);

  get _desc {
    if (testReport.reportStatus != ReportStatus.complete) {
      // return ResultDescription.positive;
      return '';
    }

    String testType = testReport.testType;
    String virusName = testReport.virusName;

    switch (testReport.finalResult) {
      case -1:
        return ResultDescription.negative(testType, virusName);
      case 0:
        return ResultDescription.invalid(testType, virusName);
      case 1:
        return ResultDescription.positive1(testType, virusName);
      case 2:
        return ResultDescription.positive2(testType, virusName);
      case 3:
        return ResultDescription.positive3(testType, virusName);
    }
    return '';
  }

  get _desc2 {
    if (testReport.reportStatus != ReportStatus.complete) {
      // return ResultDescription.positive;
      return '';
    }

    String testType = testReport.testType;
    String virusName = testReport.virusName;

    switch (testReport.finalResult) {
      case -1:
        return ResultDescription.negative(testType, virusName);
      case 0:
        return ResultDescription.invalid(testType, virusName);
      case 1:
        return ResultDescription.positive1(testType, virusName);
      case 2:
        return ResultDescription.positive2(testType, virusName);
      case 3:
        return ResultDescription.positive3(testType, virusName);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // buildInfoForm('Device ID', testReport.deviceName ?? 'Unknown Device'),
        buildInfoForm('Test Taker', testReport.name),
        buildInfoForm(
          'Date of Birth',
          formatBirth(testReport.birthday),
        ),
        buildInfoForm(
          'Date & Time',
          formatDate(testReport.startAt),
        ),
        buildInfoForm(
          'Device information',
          testReport.serial,
        ),
        buildResultForm(testReport),
        const SizedBox(height: 16, width: double.infinity),
        buildDesc(),
      ],
    );
  }

  Widget buildInfoForm(
    String label,
    String content, {
    Color textColor = Colors.black,
    Widget? child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xffC5C5C6),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xff595858),
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: textColor,
                  ),
                ),
                if (child != null) child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDesc() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 5),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xffC5C5C6),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Understand Your Result',
              style: TextStyle(
                color: Color(0xff595858),
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _desc,
          style: const TextStyle(
            color: Color(0xff717071),
          ),
        ),
        // const SizedBox(height: 16),
        // Row(
        //   children: [
        //     Container(
        //       margin: const EdgeInsets.only(top: 5),
        //       width: 12,
        //       height: 12,
        //       decoration: BoxDecoration(
        //         color: const Color(0xffC5C5C6),
        //         borderRadius: BorderRadius.circular(20),
        //       ),
        //     ),
            // const SizedBox(width: 16),
            // const Text(
            //   'What you should do:',
            //   style: TextStyle(
            //     color: Color(0xff595858),
            //     fontSize: 20,
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
        //   ],
        // ),
        // const SizedBox(height: 16),
        // Text(
        //   _desc2,
        //   style: const TextStyle(
        //     color: Color(0xff717071),
        //   ),
        // ),
      ],
    );
  }

  String formatDate(String? timeStr) {
    if (timeStr == null) {
      return '-';
    }
    final date = DateTime.parse(timeStr).toLocal();
    final str =
        DateFormat('dd MMM yyyy HH:mm').format(date) + '  ' + date.timeZoneName;
    return str;
  }

  String formatBirth(String? timeStr) {
    if (timeStr == null) {
      return '-';
    }
    final date = DateTime.parse(timeStr).toLocal();
    final str =
        DateFormat('dd MMM yyyy').format(date) + '  ' + date.timeZoneName;
    return str;
  }

  buildResultForm(TestReport testReport) {
    String label = '${testReport.testType} ';
    Color textColor = Colors.black;
    // String testResult = '';
    Widget? child;
    if (testReport.reportStatus != ReportStatus.complete) {
      switch (testReport.reportStatus) {
        case ReportStatus.cancel:
          label = 'Canceled';
          textColor = Colors.red;
          break;
        case ReportStatus.running:
          label = 'Running';
          textColor = cons.primary;
          // textColor = cons.primary;
          break;
        case ReportStatus.pending:
        default:
          label = 'Pending';
          textColor = const Color(0xff444444);
          break;
      }
    } else {
      switch (testReport.finalResult) {
        case -1:
          label += 'NEGATIVE';
          textColor = const Color(0xff39B54A);
          child = buildDetailResult(testReport);
          break;
        case 0:
          label += 'INVALID';
          textColor = const Color(0xffE7B53E);
          // child = buildDetailResult(testReport);
          break;
        case 1:
          if(testReport.testType == 'COVID-19')
          {
            label += 'POSITIVE';
            textColor = const Color(0xffC50018);
            child = buildDetailResult(testReport);
          }
          else
          {
            label += 'A & B POSITIVE';
            textColor = const Color(0xffC50018);
            child = buildDetailResult(testReport);
          }
          break;
        case 2:
          label += 'A POSITIVE';
          textColor = const Color(0xffC50018);
          child = buildDetailResult(testReport);
          break;
        case 3:
          label += 'B POSITIVE';
          textColor = const Color(0xffC50018);
          child = buildDetailResult(testReport);
          break;
      }
    }

    return buildInfoForm(
      'Test Result',
      label,
      textColor: textColor,
      child: child,
    );
  }

  Widget buildDetailResult(TestReport report) {
    final col1 = report.pd1 == 1
        ? 'Detected${(report.fittingDataCt != null && double.parse(report.fittingDataCt!.replaceAll('{', '').replaceAll('}', '').split(',')[0]) > 0) ? " (Ct : " + double.parse(report.fittingDataCt!.replaceAll('{', '').replaceAll('}', '').split(',')[0]).toStringAsFixed(1) + ")" : ""}'
        : 'Not Detected';
    final col2 = report.pd2 == 1
        ? 'Detected${(report.fittingDataCt != null && double.parse(report.fittingDataCt!.replaceAll('{', '').replaceAll('}', '').split(',')[1]) > 0) ? " (Ct : " + double.parse(report.fittingDataCt!.replaceAll('{', '').replaceAll('}', '').split(',')[1]).toStringAsFixed(1) + ")" : ""}'
        : 'Not Detected';
    final col3 = report.pd3 == 1 ? 'Valid' : 'Invalid';
    // const textStyle = TextStyle(
    //   fontWeight: FontWeight.w500,
    // );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        children: [
          TableRow(
            children: [
              Text(report.jin1),
              Text(' : $col1'),
            ],
          ),
          TableRow(
            children: [
              Text(report.jin2),
              Text(' : $col2'),
            ],
          ),
          TableRow(
            children: [
              const Text('Control'),
              Text(' : $col3'),
            ],
          )
        ],
      ),
    );
  }
}
