import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:videoplayer/screens/homescreen/homescreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  final storage = GetStorage();
  FirebaseAuth auth = FirebaseAuth.instance;
  bool otpVisibility = false;
  User? user;
  String verificationID = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Drive Player", style: TextStyle(fontSize: 24,),),
        backgroundColor: Colors.black,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/images/icon.jpg",height: 125,),
            const SizedBox(height: 100,),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Name',
              ),
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 10,),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                hintText: 'Phone Number',
                prefix: Padding(padding: EdgeInsets.all(4),
                  child: Text('+91'),
                ),
              ),
              maxLength: 10,
              keyboardType: TextInputType.phone,
            ),

            Visibility(
              child: TextField(
                controller: otpController,
                decoration: const InputDecoration(
                  hintText: 'OTP',
                  prefix: Padding(padding: EdgeInsets.all(4),
                    child: Text(''),
                  ),
                ),
                maxLength: 6,
                keyboardType: TextInputType.number,
              ),
              visible: otpVisibility,
            ),
            const SizedBox(height: 20,),
            MaterialButton(
              color: Colors.black,
              onPressed: () {
                if (otpVisibility) {
                  verifyOTP();
                } else {
                  loginWithPhone();
                }
              },
              child: Padding(
                padding: EdgeInsets.only(left: 7,right: 7,top: 3,bottom: 3),
                child: Text(
                  otpVisibility ? "Verify" : "Login",
                  style: const TextStyle(color: Colors.white, fontSize: 20,),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void loginWithPhone() async {
    auth.verifyPhoneNumber(
      phoneNumber: "+91" + phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then((value) {
          print("You are logged in successfully");
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        otpVisibility = true;
        verificationID = verificationId;
        setState(() {});
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void verifyOTP() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationID, smsCode: otpController.text);

    await auth.signInWithCredential(credential).then(
          (value) {
        setState(() {
          user = FirebaseAuth.instance.currentUser;
        });
      },
    ).whenComplete(
          () {
        if (user != null) {
          Fluttertoast.showToast(
            msg: "You are logged in successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          storage.write('name', nameController.text);
          Navigator.pushNamedAndRemoveUntil(context, "/homescreen", (route) => false);
         // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(),),);
        } else {
          Fluttertoast.showToast(
            msg: "your login is failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      },
    );
  }
}