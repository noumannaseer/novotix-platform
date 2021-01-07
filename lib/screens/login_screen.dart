import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../utils/multilang_strings.dart';
import '../network/authentication.dart';
import '../res.dart';
import '../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String username = '';
  String password = '';
  bool _isLoading = false;
  bool _isIncorrect = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Scaffold(
          body: Stack(
            children: [
              Image.asset(
                Res.login_image,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 26.0, left: 31),
                  child: Image.asset(
                    Res.logo,
                    width: 200,
                  ),
                ),
              ),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextField(
                      onChanged: (usernameVal) {
                        setState(() {
                          username = usernameVal;
                        });
                      },
                      hint: MultiLang.currentLanguage.username,
                      onError: _isIncorrect,
                      inputType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      onChanged: (passwordVal) {
                        setState(() {
                          password = passwordVal;
                        });
                      },
                      hint: MultiLang.currentLanguage.password,
                      onError: _isIncorrect,
                      isPasswordField: true,
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 36,
                left: 50,
                right: 50,
                child: SafeArea(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.83,
                    height: MediaQuery.of(context).size.height * 0.06,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      color: kMainBlueColor,
                      padding: EdgeInsets.all(0),
                      disabledColor: kMainBlueColor.withOpacity(0.5),
                      disabledTextColor: Colors.grey,
                      onPressed: username == '' || password == ''
                          ? null
                          : () async {
                              setState(() {
                                _isLoading = true;
                              });
                              bool isIncorrect = await AuthService()
                                  .login(username, password, context);
                              setState(() {
                                _isIncorrect = isIncorrect;
                                _isLoading = false;
                              });
                            },
                      child: Text(
                        MultiLang.currentLanguage.login,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final Function onChanged;
  final String hint;
  final bool isPasswordField;
  final TextInputType inputType;
  final bool onError;

  const CustomTextField({
    @required this.onChanged,
    @required this.hint,
    this.isPasswordField = false,
    this.inputType,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.83,
      // height: MediaQuery.of(context).size.height * 0.06,
      child: TextFormField(
        keyboardType: inputType ?? TextInputType.text,
        obscureText: isPasswordField,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50.0),
            ),
          ),
          contentPadding:
              EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          hintText: hint,
          errorText: onError ? '' : null,
          hintStyle: TextStyle(
            fontSize: 12,
            fontFamily: 'Poppins',
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.86),
        ),
      ),
    );
  }
}
