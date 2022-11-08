import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:videoplayer/screens/homescreen/homescreen.dart';
import 'package:videoplayer/screens/loginscreen/loginscreen.dart';
import 'package:videoplayer/screens/splashscreen/splashscreen.dart';
import 'package:videoplayer/themes/themestate.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  runApp( ChangeNotifierProvider<ThemeState>(
    create: (context) => ThemeState(),
    child: MyApp(),),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Provider.of<ThemeState>(context).theme == ThemeType.DARK ? ThemeData.dark(): ThemeData.light(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        "/" : (context) => SplashScreen(),
        "/loginscreen" : (context) => LoginScreen(),
        "/homescreen" : (context) => HomeScreen(),
      },
      title: 'Drive Player',
    );
  }
}