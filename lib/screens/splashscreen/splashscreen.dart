import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);
  late double screenwidth;
  late double screenheight;
  final storage = GetStorage();

  @override
  Widget build(BuildContext context) {
    screenwidth = MediaQuery.of(context).size.width;
    screenheight = MediaQuery.of(context).size.height;
    Future.delayed(Duration(seconds: 2),() => navigateToNextPage(context));
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Image.asset("assets/images/icon.jpg",width: screenwidth * 0.6,),
        ),
      ),
    );
  }

  void navigateToNextPage(BuildContext context) async {
    String name = storage.read('name') ?? "";
    try{
      if(name != null && name != ""){
        Navigator.popAndPushNamed(context, "/homescreen");
      }else{
        Navigator.popAndPushNamed(context, "/loginscreen");
      }
    }catch (e){
      Navigator.popAndPushNamed(context, "/loginscreen");
    }
  }
}
