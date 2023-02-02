import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';
import 'package:untitled/pages/profile.dart';
import 'package:untitled/pages/home_page.dart';
import 'package:untitled/helper/helper_function.dart';
import 'package:untitled/pages/auth/login_page.dart';
import 'package:untitled/service/database_service.dart';
import 'package:untitled/shared/constants.dart';
import 'package:untitled/theme/model_theme.dart';
import 'package:untitled/theme/theme_preference.dart';

import 'Language/localString.dart';
Reference ref=FirebaseStorage.instance.ref().child("profilePic.jpg");
void main()async{

  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: Constants.apiKey,
            appId: Constants.appId,
            messagingSenderId: Constants.messagingSenderId,
            projectId: Constants.projectId,
          storageBucket:Constants.storageBucket,
        ));
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSignedIn=false;
  String email = "";
  User? user;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserLoggedInStatus();
    gettingUserData();
    getUserDp();
  }
  themeListener(){
    if(mounted){
      setState(() {
      });
    }
  }
  getUserLoggedInStatus()async{
    await HelperFunctions.getUserLoggedInStatus().then((value) {
      if(value!=null){
        setState(() {
          _isSignedIn=value;
        });
      }
    });
  }
  gettingUserData() async {
    await HelperFunctions.getUserEmailfromSF().then((value) {
      setState(() {
        email = value!;
      });
      user = FirebaseAuth.instance.currentUser;
    });
  }

  Reference ref=FirebaseStorage.instance.ref().child("profilePic.jpg");
  getUserDp(){
    ref.getDownloadURL().then((value)async{
      await DatabaseService(uid:user?.uid).updateProfile(value).whenComplete(()async {
        await DatabaseService(uid: user?.uid).getUserProfile().then((value) {
          setState(() {
            profilePic=value;
            print(profilePic);
          });
        });
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ModelTheme(),
      child: Consumer<ModelTheme>(
          builder: (context, ModelTheme themeNotifier, child) {
            return GetMaterialApp(
              translations: LocalString(),
              locale: Locale('en','US'),
              theme: themeNotifier.isDark
                  ? ThemeData(
                brightness: Brightness.dark,
              )
                  : ThemeData(
                  brightness: Brightness.light,
                  primaryColor: Color(0xFFBA133B),
                  primarySwatch: Colors.pink,
              ),
              debugShowCheckedModeBanner: false,
              home: _isSignedIn?const HomePage():const LoginPage(),
            );
          }),
    );
  }
}
