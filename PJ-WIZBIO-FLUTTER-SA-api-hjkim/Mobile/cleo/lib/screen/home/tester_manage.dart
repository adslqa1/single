import 'package:cleo/model/test_report.dart';
import 'package:cleo/model/tester.dart';
import 'package:cleo/provider/auth.dart';
import 'package:cleo/provider/bluetooth.provider.dart';
import 'package:cleo/screen/common/confirm_button.dart';
import 'package:cleo/screen/common/custom_appbar.dart';
import 'package:cleo/util/sql_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cleo/constants.dart' as cons;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TesterMangeScreen extends StatefulWidget {
  static const routeName = '/testerManage';

  const TesterMangeScreen({Key? key}) : super(key: key);

  @override
  State<TesterMangeScreen> createState() => _TesterMangeScreenState();
}

class _TesterMangeScreenState extends State<TesterMangeScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _birthdayCtrl;
  late TextEditingController _genderCtrl;

  final _formKey = GlobalKey<FormState>();

  List<Tester> _testerList = [];
  Tester? _selectedTester;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _birthdayCtrl = TextEditingController();
    _genderCtrl = TextEditingController();

    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        useBack: true,
        title: 'Select Test taker',
        reading: IconButton(
          icon: const Icon(CupertinoIcons.add),
          onPressed: () => testerDialog(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _testerList.isEmpty
                    ? Expanded(
                        child: Center(
                          child: InkWell(
                            child: const Text(
                              'You should add test taker’s name and date of birth in advance.\nAdd a test taker name by clicking ‘+’ on upper corner or just touch this screen.',
                              style: TextStyle(fontSize: 22),
                              textAlign: TextAlign.center,
                            ),
                            onTap: () => testerDialog(context),
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _testerList.length,
                          itemBuilder: (context, index) {
                            final Tester tester = _testerList[index];
                            return userCard(tester);
                          },
                        ),
                      ),
                if (_testerList.isNotEmpty)
                  ConfirmButton(
                    onPressed: changeUser,
                    label: 'Select',
                    backgroundColor: MaterialStateProperty.all(
                      _selectedTester == null ? Colors.grey : cons.primary,
                    ),
                  )
              ],
            )),
      ),
    );
  }

  void testerDialog(
    BuildContext context, {
    bool modify = false,
  }) async {
    final String title = modify ? 'Modify Test taker' : 'Add Test taker';

    await showDialog(
      context: context,
      routeSettings: const RouteSettings(name: 'dialog'),
      builder: (ctx) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Dialog(
                  insetPadding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: cons.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                resetCtrl();
                              },
                              icon: const Icon(CupertinoIcons.clear),
                            )
                          ],
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextFormField(
                                  controller: _nameCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Tester Name',
                                    prefixIcon:
                                        Icon(CupertinoIcons.profile_circled),
                                  ),
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter a valid name';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _birthdayCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Tester Birthday',
                                    prefixIcon: Icon(CupertinoIcons.calendar),
                                  ),
                                  readOnly: true,
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter a valid name';
                                    } else {
                                      return null;
                                    }
                                  },
                                  onTap: tapBirthday,
                                ),
                                // const SizedBox(height: 16),
                                // TextFormField(
                                //   controller: _genderCtrl,
                                //   decoration: const InputDecoration(
                                //     labelText: 'Tester Gender',
                                //     prefixIcon:
                                //         Icon(CupertinoIcons.profile_circled),
                                //   ),
                                //   readOnly: true,
                                //   validator: (String? value) {
                                //     if (value == null || value.isEmpty) {
                                //       return 'Enter a valid name';
                                //     } else {
                                //       return null;
                                //     }
                                //   },
                                //   onTap: () {
                                //     showCupertinoModalPopup<void>(
                                //       context: context,
                                //       builder: (BuildContext context) =>
                                //           CupertinoActionSheet(
                                //         // title: const Text('Title'),
                                //         // message: const Text('Message'),
                                //         actions: <CupertinoActionSheetAction>[
                                //           CupertinoActionSheetAction(
                                //             child: const Text('Male'),
                                //             onPressed: () {
                                //               Navigator.pop(context);
                                //               _genderCtrl.text = 'male';
                                //             },
                                //           ),
                                //           CupertinoActionSheetAction(
                                //             child: const Text('Female'),
                                //             onPressed: () {
                                //               Navigator.pop(context);
                                //               _genderCtrl.text = 'female';
                                //             },
                                //           ),
                                //           CupertinoActionSheetAction(
                                //             child: const Text('other'),
                                //             onPressed: () {
                                //               Navigator.pop(context);
                                //               _genderCtrl.text = 'other';
                                //             },
                                //           ),
                                //           CupertinoActionSheetAction(
                                //             child: const Text('not to answer'),
                                //             onPressed: () {
                                //               Navigator.pop(context);
                                //               _genderCtrl.text =
                                //                   'not to answer';
                                //             },
                                //           ),
                                //         ],
                                //       ),
                                //     );
                                //   },
                                // ),
                                const SizedBox(height: 8 * 10),
                                FlatConfirmButton(
                                  onPressed: modify ? modifyTester : addTester,
                                  label: modify ? 'MODIFY' : 'ADD',
                                  reversal: true,
                                ),
                                const SizedBox(height: 24),
                                if (modify)
                                  FlatConfirmButton(
                                    onPressed: deleteTester,
                                    label: 'DELETE',
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                  )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
        ;
      },
    );
  }

  init() async {
    List<Map> data = await SqlTester.loadTester();

    setState(() {
      _testerList = data.map((val) => Tester(val)).toList();
    });
  }

  void tapBirthday() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(DateTime.now().year - 22),
      firstDate: DateTime(1890),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (selectedDate != null) {
      String formatDate = DateFormat('yyyy-MM-dd').format(selectedDate);

      _birthdayCtrl.text = formatDate;
    }
  }

  void tapGender() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: const Text('Male'),
            onPressed: () {
              Navigator.pop(context);
              _genderCtrl.text = 'male';
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Female'),
            onPressed: () {
              Navigator.pop(context);
              _genderCtrl.text = 'female';
            },
          )
        ],
      ),
    );
  }

  void changeUser() async {
    if (_selectedTester == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 80, right: 16, left: 16),
        content: Text('Please select Tester'),
        duration: Duration(milliseconds: 500),
      ));
      return;
    }

    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    authProvider.setTester(_selectedTester!);

    Navigator.of(context).pop();
  }

  void addTester() async {
    if (!_formKey.currentState!.validate()) return;

    int genderVal = 0;
    switch (_genderCtrl.text) {
      case 'male':
        genderVal = 0;
        break;
      case 'female':
        genderVal = 1;
        break;
      case 'other':
        genderVal = 2;
        break;
      case 'not to answer':
        genderVal = 3;
        break;
    }
    Object obj = {
      'name': _nameCtrl.text,
      'birthday': _birthdayCtrl.text,
      'gender': genderVal,
    };
    Tester tester = Tester(obj);

    final testerId = await SqlTester.insertTester(tester);
    resetCtrl();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 80, right: 16, left: 16),
      content: Text('tester(${tester.name}) has been added'),
    ));

    init();

    // ---- START :: temp code for demo
    if (tester.name == 'test_user') {
      final device =
          Provider.of<BluetoothProvider>(context, listen: false).currentDevice;

      final reportBase = TestReport(
        userId: testerId,
        name: tester.name,
        testType: 'COVID-19',
        birthday: tester.birthday,
        gender: tester.gender,
        macAddress: device?.device.id.toString() ?? '',
        serial: device?.serial ?? '',
        expire: '24.10.2022',
        lotNum: '5A1021-01',
        ctValue: '100',
        reportStatus: ReportStatus.complete,
      );
      reportBase.deviceName = 'Android Phone';
      reportBase.startAt = DateTime.now().toIso8601String();
      reportBase.serial = 'II04-Aa1-00004';
      // insert positive
      reportBase.result1 = 10;
      reportBase.result2 = 10;
      reportBase.result3 = 10;
      await SqlReport.insertReport(reportBase);
      // insert invalid
      reportBase.result1 = 10;
      reportBase.result2 = 10;
      reportBase.result3 = 0;
      await SqlReport.insertReport(reportBase);

      // insert negative
      reportBase.result1 = 0;  //2023.10.16_CJH
      reportBase.result2 = 0;
      reportBase.result3 = 10;
      await SqlReport.insertReport(reportBase);
    }
    // ---- END :: temp code for demo
  }

  void modifyTester() async {
    if (!_formKey.currentState!.validate()) return;

    int genderVal = 0;
    switch (_genderCtrl.text) {
      case 'male':
        genderVal = 0;
        break;
      case 'female':
        genderVal = 1;
        break;
      case 'other':
        genderVal = 2;
        break;
      case 'not to answer':
        genderVal = 3;
        break;
    }

    Object obj = {
      'name': _nameCtrl.text,
      'birthday': _birthdayCtrl.text,
      'gender': genderVal,
    };
    Tester tester = Tester(obj);

    await SqlTester.updateTester(_selectedTester!.id, tester);

    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    authProvider.setTester(tester);

    resetCtrl();

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 80, right: 16, left: 16),
      content: Text('tester(${tester.name}) has been modified'),
    ));

    init();
  }

  Future<void> deleteTester() async {
    showDialog(
      context: context,
      routeSettings: const RouteSettings(name: 'dialog'),
      builder: (context) => AlertDialog(
        content: const Text('Are you sure ?'),
        actions: [
          TextButton(
            child: const Text(
              "CONFIRM",
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () async {
              final AuthProvider authProvider =
                  Provider.of<AuthProvider>(context, listen: false);

              await SqlTester.deleteTesterById(_selectedTester!.id);

              if (authProvider.currentTester != null &&
                  _selectedTester != null &&
                  authProvider.currentTester!.id == _selectedTester!.id) {
                authProvider.setTester(null);
              }

              Navigator.of(context).popUntil((route) =>
                  route.isFirst ||
                  route.settings.name == TesterMangeScreen.routeName);

              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(bottom: 80, right: 16, left: 16),
                content: Text('tester has been deleted'),
              ));

              init();
            },
          ),
          TextButton(
            child: const Text("CANCEL"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void resetCtrl() {
    _nameCtrl.text = '';
    _birthdayCtrl.text = '';
    _genderCtrl.text = '';
  }

  Widget userCard(Tester tester) {
    final bool isSelected = _selectedTester == tester;

    final date = DateTime.parse(tester.birthday).toLocal();
    final str = DateFormat('dd MMM, yyyy').format(date);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedTester = tester;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? cons.primary : const Color(0xffEEEFEF),
          borderRadius: BorderRadius.circular(8),
        ),
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
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      tester.name[0],
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
                      tester.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      str,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xff717071),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            IconButton(
              onPressed: () {
                _nameCtrl.text = tester.name;
                _birthdayCtrl.text = tester.birthday;

                String genderVal = '';
                switch (tester.gender) {
                  case 0:
                    genderVal = 'male';
                    break;
                  case 1:
                    genderVal = 'female';
                    break;
                  case 2:
                    genderVal = 'other';
                    break;
                  case 3:
                    genderVal = 'not to answer';
                    break;
                }
                _genderCtrl.text = genderVal;

                setState(() {
                  _selectedTester = tester;
                });

                testerDialog(context, modify: true);
              },
              icon: Icon(
                CupertinoIcons.pencil_ellipsis_rectangle,
                color: isSelected ? Colors.white : Colors.black,
              ),
            )
          ],
        ),
      ),
    );
  }
}
