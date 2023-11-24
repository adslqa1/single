import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../provider/auth.dart';

class DeleteAccountScreen extends StatefulWidget {
  static const routeName = '/deleteAccount';

  const DeleteAccountScreen({Key? key}) : super(key: key);

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  late TextEditingController _emailCtrl;
  late TextEditingController _pwCtrl;

  bool _remember = false;

  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();

    _emailCtrl = TextEditingController();
    _pwCtrl = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: constraints.maxHeight * 0.3,
                          child: Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'CLEO',
                                  style: TextStyle(
                                    color: const Color(0xff717071),
                                    fontSize: size.width * 0.12,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '™',
                                  style: TextStyle(
                                    color: const Color(0xff717071),
                                    fontSize: size.width * 0.04,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  'O',
                                  style: TextStyle(
                                    color: const Color(0xff5588F4),
                                    fontSize: size.width * 0.12,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'NE',
                                  style: TextStyle(
                                    color: const Color(0xff717071),
                                    fontSize: size.width * 0.12,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: const Text(
                            'DELETE ACCOUNT',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(114, 114, 114, 1),
                            ),
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                  controller: _emailCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon:
                                        Icon(CupertinoIcons.person_circle_fill),
                                  ),
                                  validator: (String? value) {
                                    String pattern =
                                        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                                        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                                        r"{0,253}[a-zA-Z0-9])?)*$";
                                    RegExp regex = RegExp(pattern);
                                    if (value == null ||
                                        value.isEmpty ||
                                        !regex.hasMatch(value)) {
                                      return 'Enter a valid email address';
                                    } else {
                                      return null;
                                    }
                                  }),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _pwCtrl,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon:
                                      Icon(CupertinoIcons.lock_circle_fill),
                                ),
                                validator: (String? value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.length < 5) {
                                    return 'Enter a valid password';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 32),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;

                              AuthCredential credential =
                                  EmailAuthProvider.credential(
                                      email: _emailCtrl.text.trim(),
                                      password: _pwCtrl.text);

                              try {
                                await FirebaseAuth.instance.currentUser!
                                    .reauthenticateWithCredential(credential);

                                await FirebaseAuth.instance.currentUser!
                                    .delete();
                                Navigator.of(context).pop();
                              } on FirebaseAuthException catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.message ?? '')),
                                );
                              }
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                              ),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: const Align(
                                child: Text(
                                  'DELETE',
                                  style: TextStyle(fontSize: 18),
                                ),
                                alignment: Alignment.center,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(bottom: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: const [
                                Center(
                                  child: Text(
                                    '© 2022 Wizbiosolutions Inc. All right reserved.',
                                    style: TextStyle(
                                      color: Color.fromRGBO(114, 114, 114, 0.8),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    'CLEO™ is a trademark of Wizbiosolutions.',
                                    style: TextStyle(
                                      color: Color.fromRGBO(114, 114, 114, 0.8),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
