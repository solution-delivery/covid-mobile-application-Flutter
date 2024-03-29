import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:covid/pages/auth/profile/step1.dart';
import 'package:covid/pages/auth/verification.dart';
import 'package:covid/utils/enums.dart';
import 'package:covid/utils/functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:covid/utils/styles.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:email_validator/email_validator.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  bool _isObscure = true;
  LogInMode _logInMode = LogInMode.phone;
  String phoneNumber = "";
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  void signIn() async {
    try {
      if (_logInMode == LogInMode.email) {
        final email = emailController.value.text;
        final password = passwordController.value.text;
        if (!EmailValidator.validate(email)) {
          showToast("Invalid email");
          return;
        } else if (password == "") {
          showToast("Please input password");
          return;
        } else {
          UserCredential user = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);
          setUserData(
            context,
            (await FirebaseFirestore.instance
                        .collection("users")
                        .doc(user.user!.uid)
                        .get())
                    .data() ??
                {},
          );
          var userData = getUserData(context);
          if (userData["name"] == "")
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SetupProfile1(
                  setupType: "email",
                  email: user.user!.email ?? "",
                ),
              ),
            );
          else {
            final uID = FirebaseAuth.instance.currentUser!.uid;

            List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
                (await FirebaseFirestore.instance
                        .collection("checkin-history")
                        .where("user_id", isEqualTo: uID)
                        .get())
                    .docs;
            documents.forEach((element) {
              element.reference.delete();
            });
            Navigator.pushNamed(context, "/home");
          }
        }
      } else {
        if (phoneNumber.length < 5) {
          showToast("Please input phone number");
          return;
        } else {
          try {
            await FirebaseAuth.instance.verifyPhoneNumber(
              phoneNumber: phoneNumber,
              verificationCompleted: (PhoneAuthCredential user) {
                print("phone auth completed");
              },
              verificationFailed: (e) {
                showToast("Invalid phone number");
              },
              codeSent: (String verificationId, int? resendToken) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Verification(
                      verificationId: verificationId,
                      verifyType: "login",
                    ),
                  ),
                );
              },
              codeAutoRetrievalTimeout: (String verificationId) {},
            );
          } catch (e) {
            showToast("The phone number isn't registered");
            print(e);
          }
        }
      }
    } catch (e) {
      showToast("Unregistered username and password");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(top: 80, left: 25, bottom: 30, right: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: MediaQuery.of(context).size.width / 3,
                fit: BoxFit.fitWidth,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _logInMode == LogInMode.phone
                      ? InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            phoneNumber = number.phoneNumber ?? "";
                          },
                          selectorConfig: SelectorConfig(
                            selectorType: PhoneInputSelectorType.DIALOG,
                            trailingSpace: false,
                            showFlags: false,
                          ),
                          maxLength: 15,
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
                    height: 8,
                  ),
                  _logInMode == LogInMode.email
                      ? TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                            ),
                          ),
                          validator: (val) =>
                              val!.length < 6 ? 'Password too short.' : null,
                          onSaved: (val) => print(val),
                          obscureText: _isObscure,
                        )
                      : Container(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        child: Text(
                          "Login with ${this._logInMode == LogInMode.email ? "phone number" : "email"}",
                          style: AppStyles.normalText,
                        ),
                        onTap: () {
                          setState(() {
                            _logInMode = _logInMode == LogInMode.email
                                ? LogInMode.phone
                                : LogInMode.email;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                    child: Text("Sign in"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(
                        double.infinity,
                        40,
                      ), // double.infinity is the width and 30 is the height
                    ),
                    onPressed: () {
                      signIn();
                    },
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed("/register");
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue),
                      minimumSize: Size(double.infinity, 40),
                    ),
                    child: Text("Register Here"),
                  ),
                  TextButton(
                    child: Text("ForgotPassword?"),
                    onPressed: () {
                      Navigator.pushNamed(context, "/reset");
                    },
                  ),
                  Text(
                    "Need Help?",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Text(
                    "Strategic Collaboration",
                    style: AppStyles.grayText10,
                  ),
                  Text(
                    "NSC•MOH•MAMPU•MCMC",
                    style: AppStyles.grayText10,
                  ),
                  Text(
                    "App Version 1.0.42",
                    style: AppStyles.grayText10,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
