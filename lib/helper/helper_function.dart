import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class HelperFunctions{
  static String userLoggedInKey='LOGGEDINKEY';
  static String userNameKey='USERNAMEKEY';
  static String userEmailKey='USEREMAILKEY';
  static String userIdKey='USERIDKEY';
          //LoggedInKey
  static Future<bool>saveUserLoggedInStatus(bool isUserLoggedIn)async{
    SharedPreferences sf=await SharedPreferences.getInstance();
    return await sf.setBool(userLoggedInKey, isUserLoggedIn);
  }
         //saveUserName
  static Future<bool>saveUserNameSF(String userName)async{
    SharedPreferences sf=await SharedPreferences.getInstance();
    return await sf.setString(userNameKey, userName);
  }

        //saveUserEmail
  static Future<bool>saveUserEmailSF(String userEmail)async{
    SharedPreferences sf=await SharedPreferences.getInstance();
    return await sf.setString(userEmailKey, userEmail);
  }

  //saveUserId
  static Future<bool>saveUserIdSF(String userId)async{
    SharedPreferences sf=await SharedPreferences.getInstance();
    return await sf.setString(userIdKey, userId);
  }


  static Future<bool?>getUserLoggedInStatus()async{
    SharedPreferences sf =await  SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }

  static Future<String?>getUserEmailfromSF()async{
    SharedPreferences sf =await  SharedPreferences.getInstance();
    return sf.getString(userEmailKey);
  }

  static Future<String?>getUserNamefromSF()async{
    SharedPreferences sf =await  SharedPreferences.getInstance();
    return sf.getString(userNameKey);
  }
  static Future<String?>getUserIdfromeSF()async{
    SharedPreferences sf=await SharedPreferences.getInstance();
    return sf.getString(userIdKey);
  }
}