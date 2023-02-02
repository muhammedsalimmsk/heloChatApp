import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:untitled/pages/profile.dart';
import 'package:untitled/pages/privacy.dart';
import 'package:untitled/widgets/widget.dart';
import '../service/auth_service.dart';
import '../theme/model_theme.dart';
import '../theme/theme_preference.dart';
import '../widgets/drawer.dart';
import 'auth/login_page.dart';
class settings_page extends StatelessWidget {
   settings_page({Key? key}) : super(key: key);

    String currentLanguage="English";

   final List locale =[
     {'name':'English','locale':const Locale('en','US')},
     {'name':'മലയാളം','locale':const Locale('ml','IN')},
   ];
   updateLanguage(Locale locale){
     Get.back();
     Get.updateLocale(locale);
   }

   buildLanguageDialog(BuildContext context){
     showDialog(context: context,
         builder: (builder){
           return AlertDialog(
             title: Text('choose lang'.tr),
             content: SizedBox(
               width: double.maxFinite,
               child: ListView.separated(
                   shrinkWrap: true,
                   itemBuilder: (context,index){
                     return Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: GestureDetector(child: Text(locale[index]['name'],style:const TextStyle(fontWeight: FontWeight.bold),),onTap: (){
                         currentLanguage=locale[index]['name'];
                         updateLanguage(locale[index]['locale']);
                       },),
                     );
                   }, separatorBuilder: (context,index){
                 return const Divider(
                   color: Colors.blue,
                 );
               }, itemCount: locale.length
               ),
             ),
           );
         }
     );
   }

  @override
  Widget build(BuildContext context) {
    AuthService authService = AuthService();
    return Consumer<ModelTheme>(
        builder: (context, ModelTheme themeNotifier, child)
    {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme
              .of(context).primaryColor,
          centerTitle: true,
          title: Text("settings".tr,
              style:const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 27)),
        ),
        drawer: const Drawer_Custom(),
        body: SettingsList(
          sections: [
            SettingsSection(
                tiles: [
                  SettingsTile.navigation(
                    leading: const Icon(Icons.language),
                    title: Text("lang".tr,style:TextStyle(fontSize: 17,fontWeight: FontWeight.bold,)),
                    value: Text(currentLanguage),
                  onPressed: (context){
                    buildLanguageDialog(context);
                  },),
                  SettingsTile(
                    leading: const Icon(Icons.person),
                    title: Text("accounts".tr,style:const TextStyle(fontSize: 17,fontWeight: FontWeight.bold,)),
                    onPressed: (context) {
                      nextScreen(context, const profile());
                    },),
                  SettingsTile(
                    title:Text("privacy".tr,style:const TextStyle(fontSize: 17,fontWeight: FontWeight.bold,),),
                    leading: const Icon(Icons.library_books),
                  onPressed:(context){
                      nextScreen(context,const PrivacyPage());
                      },),
                  SettingsTile.switchTile(
                    onToggle: (value) {
                      themeNotifier.isDark
                          ? themeNotifier.isDark = false
                          : themeNotifier.isDark = true;
                    },
                    initialValue:themeNotifier.isDark,
                    leading: const Icon(Icons.format_paint),
                    title:Text('dark'.tr,style:const TextStyle(fontSize: 17,fontWeight: FontWeight.bold,)),
                  ),
                  SettingsTile(
                    onPressed: (context) async {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("logout".tr),
                              content:Text("want logout".tr),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child:Text("cancel".tr)),
                                TextButton(
                                    onPressed: () {
                                      authService.signOut().whenComplete(() {
                                        nextScreenReplace(
                                            context, const LoginPage());
                                      });
                                    },
                                    child:Text("continue".tr))
                              ],
                            );
                          });
                    },
                    title:Text("logOut".tr,style:const TextStyle(fontSize: 17,fontWeight: FontWeight.bold,)),
                    leading: const Icon(Icons.logout),)
                ]
            )
          ],

        ),
      );
    }
    );
  }
}
