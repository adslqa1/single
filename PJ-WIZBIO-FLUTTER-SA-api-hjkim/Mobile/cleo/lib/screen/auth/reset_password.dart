import 'package:cleo/provider/auth.dart';
import 'package:cleo/screen/common/confirm_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const routeName = '/resetPassword';
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late TextEditingController _emailCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _emailCtrl = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: InkWell(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: const SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: Icon(
                                        CupertinoIcons.arrow_left,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'CLEO',
                                        style: TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.w900,
                                          color:
                                              Color.fromRGBO(114, 114, 114, 1),
                                        ),
                                      ),
                                      Text(
                                        '™',
                                        style: TextStyle(
                                          height: 2,
                                          color:
                                              Color.fromRGBO(114, 114, 114, 1),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'O',
                                        style: TextStyle(
                                          fontSize: 40,
                                          color:
                                              Color.fromRGBO(45, 137, 248, 1),
                                        ),
                                      ),
                                      Text(
                                        'NE',
                                        style: TextStyle(
                                          fontSize: 40,
                                          color:
                                              Color.fromRGBO(114, 114, 114, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: const Text(
                            'RESET PASSWORD',
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
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  // border: OutlineInputBorder(),
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
                                },
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 32),
                            child: ConfirmButton(
                              label: 'SEND TO EMAIL',
                              onPressed: resetPassword,
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

  void resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await AuthProvider.auth.sendPasswordResetEmail(email: _emailCtrl.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email is sent')),
      );
      _emailCtrl.text = '';
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error resetting')),
      );
    }
  }
}
