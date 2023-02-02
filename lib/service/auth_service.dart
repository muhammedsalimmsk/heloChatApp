import 'package:firebase_auth/firebase_auth.dart';

import '../helper/helper_function.dart';
import 'database_service.dart';

class AuthService{
  final FirebaseAuth firebaseAuth=FirebaseAuth.instance;

  //login

  Future loginUserWithNameAndPassword(String email,String password )async{
    try{
      User user =(await firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).
      user!;
      if (user!=null){
        return true;
      }

    }on FirebaseException catch (e){
      //print(e);
      return e.message;
    }
  }


//register
  Future registerUserWithEmailAndPassword(String fullname,String email,String password )async{
         try{
           User user =(await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).
           user!;
           if (user!=null){
             await DatabaseService(uid:user.uid).updateUserData(fullname,email);
             return true;
           }

         }on FirebaseException catch (e){
           //print(e);
           return e.message;
         }
  }
  Future signOut()async{
    try{
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserNameSF('');
      await HelperFunctions.saveUserEmailSF('');
      await firebaseAuth.signOut();
    }catch(e){
     return null;
    }
  }
}