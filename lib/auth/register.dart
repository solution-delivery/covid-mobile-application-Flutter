import 'package:covid/utils/enums.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:covid/utils/styles.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  LogInMode _logInMode = LogInMode.phone;
  String phoneNumber = "";

  void showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 2,
      fontSize: 15,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.lightBlue,
      textColor: Colors.blue,
    );
  }

  void registerUser() async {
    if (_logInMode == LogInMode.phone) {
      try {
        PhoneNumber number =
            await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber);
        int countryCodeLength = number.dialCode?.length ?? 0;
        if (phoneNumber.length - countryCodeLength < 11)
          showToast("Invalid phone number");
        else {
          Navigator.pushNamed(context, "/verification");
        }
      } catch (e) {
        showToast("Invalid phone number");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = new TextEditingController();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: GestureDetector(
          child: Center(
            child: Icon(
              Icons.keyboard_arrow_left,
              color: Colors.blue,
              size: 40,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 90,
          padding: EdgeInsets.only(top: 80, left: 25, bottom: 50, right: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: MediaQuery.of(context).size.width / 2 - 20,
                fit: BoxFit.fitWidth,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Registration", style: AppStyles.titleText),
                  SizedBox(height: 20),
                  _logInMode == LogInMode.phone
                      ? InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            phoneNumber = number.phoneNumber ?? "";
                          },
                          selectorConfig: SelectorConfig(
                            selectorType: PhoneInputSelectorType.DIALOG,
                            trailingSpace: false,
                          ),
                          maxLength: 10,
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.disabled,
                          selectorTextStyle: TextStyle(color: Colors.black),
                          formatInput: true,
                          keyboardType: TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          inputDecoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
                            focusColor: Colors.black12,
                            fillColor: Colors.black12,
                            hoverColor: Colors.black12,
                            labelText: "Mobile Number",
                          ),
                          hintText: "Mobile Number",
                        )
                      : TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
                            hintText: "Email",
                          ),
                        ),
                  SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    child: Text("Register"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(
                        double.infinity,
                        40,
                      ), // double.infinity is the width and 30 is the height
                    ),
                    onPressed: () => registerUser(),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    child: Center(
                      child: Text(
                        "I would like to use ${this._logInMode == LogInMode.phone ? "email" : "phone number"} to register",
                        style: AppStyles.defaultText,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _logInMode = _logInMode == LogInMode.phone
                            ? LogInMode.email
                            : LogInMode.phone;
                      });
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
