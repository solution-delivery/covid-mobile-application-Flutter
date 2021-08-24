import 'dart:async';

import 'package:covid/auth/profile/step1.dart';
import 'package:covid/components/textbox.dart';
import 'package:covid/components/textedit.dart';
import 'package:covid/utils/functions.dart';
import 'package:covid/utils/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Verification extends StatefulWidget {
  final String verificationId;
  const Verification({required this.verificationId, Key? key})
      : super(key: key);

  @override
  _VerificationState createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  TextEditingController otpController = new TextEditingController();
  Timer _timer = new Timer(Duration.zero, () {});
  int duration = 300;
  bool isLimit = true;
  String verificationId = "";

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    setState(() {
      duration = 300;
    });
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (duration > 0)
          setState(() {
            duration--;
          });
        else
          setState(() {
            isLimit = false;
            _timer.cancel();
          });
      },
    );
  }

  void resendOTP() async {
    if (duration != 0) return;
    try {
      var userData = getUserData(context);
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: userData["phoneNumber"],
        verificationCompleted: (PhoneAuthCredential user) {},
        verificationFailed: (e) {},
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            this.verificationId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
      setState(() {
        duration = 300;
      });
      startTimer();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    setState(() {
      verificationId = widget.verificationId;
    });
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void onSubmit() async {
      if (duration == 0) {
        showToast("Your OTP code is expired");
      } else {
        try {
          PhoneAuthCredential _credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: otpController.value.text);
          await FirebaseAuth.instance.signInWithCredential(_credential);
          var userData = getUserData(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SetupProfile1(phone: userData["phoneNumber"]),
            ),
          );
        } catch (e) {
          print(e);
          showToast("Invalid OTP code");
        }
      }
    }

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
          padding: EdgeInsets.only(top: 0, left: 25, bottom: 30, right: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: MediaQuery.of(context).size.width / 2,
                  fit: BoxFit.fitWidth,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextBox(
                    value: "OTP verification",
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    padding: 10,
                  ),
                  TextBox(
                    value:
                        "Enter the OTP sent to you registered phone number/email address prince891028@gmail.com",
                    fontColor: Colors.black38,
                    fontSize: 13,
                    padding: 15,
                  ),
                  TextBox(
                    value: "OTP",
                    fontColor: Colors.black87,
                    fontSize: 15,
                    padding: 10,
                  ),
                  TextEdit(
                    controller: otpController,
                    maxLength: 6,
                    type: "number",
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Didn't receive yet? ",
                            style: AppStyles.grayText15,
                          ),
                          GestureDetector(
                            child: Text(
                              "Resend OTP",
                              style: isLimit
                                  ? AppStyles.disableText
                                  : AppStyles.defaultText,
                            ),
                            onTap: () {
                              resendOTP();
                            },
                          ),
                        ],
                      ),
                      Text(
                        "${duration ~/ 60}m ${duration % 60}s",
                        style: AppStyles.greenText,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "An OTP will be sent to your registered phone number/email. Kindly enter above to register. If you do not receive it within 5 minutes, Kindly try again.",
                    style: AppStyles.grayText12,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    child: Text("Submit"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(
                        double.infinity,
                        40,
                      ), // double.infinity is the width and 30 is the height
                    ),
                    onPressed: onSubmit,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
