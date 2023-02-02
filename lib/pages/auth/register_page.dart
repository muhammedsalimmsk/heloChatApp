import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:untitled/helper/helper_function.dart';
import 'package:untitled/pages/auth/login_page.dart';
import 'package:untitled/pages/home_page.dart';
import 'package:untitled/service/auth_service.dart';
import 'package:untitled/widgets/widget.dart';
class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading=false;
  AuthService authService=AuthService();
  final _formKey=GlobalKey<FormState>();
  TextEditingController emailController=TextEditingController();
  TextEditingController passwordController=TextEditingController();
  TextEditingController confimController=TextEditingController();
  TextEditingController fullnameController=TextEditingController();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      
      body:Form(
        key: _formKey,
        child:_isLoading ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) :SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
               //const  SizedBox(
                  //height: 30,
                //),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 100,
                    ),
                     const SizedBox(
                      width: 15,
                    ),
                    Image.asset(
                      'assets/images/Helo Chat.png',
                      width: 100,
                    )
                  ],
                ),
                const Text('Sign Up Now ',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontFamily: 'Hurrycane',
                        fontSize: 44,
                        fontWeight: FontWeight.bold)),
                const Text(
                  'Create your account now to ',

                  style: TextStyle(fontSize: 20),maxLines: 2,
                ),
                const Text('chat and explore',style: TextStyle(fontSize: 20),),
                Image.asset(
                  'assets/images/register.png',
                  width: 260,
                  fit: BoxFit.fill,
                ),
                //SizedBox(height: 0,),
                Container(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: fullnameController,
                        decoration: textInputDecoration.copyWith(
                            labelText: 'Full Name',
                            prefixIcon: Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                            )),
                        validator: (val) {
                          if (val!.length < 4) {
                            return 'User Name must be at least 4 characters';
                          } else {
                            return null;
                          }
                        }
                        ),
                      const SizedBox(height: 15,),
                      TextFormField(
                        controller: emailController,
                        decoration: textInputDecoration.copyWith(
                            labelText: 'Email',
                            prefixIcon: Icon(
                              Icons.email,
                              color: Theme.of(context).primaryColor,
                            )),
                        validator: (val) {
                          return RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(val!)
                              ? null
                              : 'Please enter a valid email';
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: passwordController,
                        decoration: textInputDecoration.copyWith(
                          labelText: 'Password',
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        validator: (val) {
                          if (passwordController.text.isEmpty){
                            return 'Please enter password';
                          }
                          if (val!.length < 6) {
                            return 'Password must be at least 6 characters';
                          } else  {
                            return null;
                          }

                        },
                        obscureText: true,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(

                        controller: confimController,
                        decoration: textInputDecoration.copyWith(
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        validator: (val) {
                          if(confimController.text.isEmpty){
                            return 'Please re-enter password';
                          }
                          if (passwordController.text!=confimController.text) {
                            return 'Confirmation password does not match the entered password';
                          }
                          else{
                            return null;
                          }
                          },

                        obscureText: true,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                       SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            register();
                          },
                        ),
                      ),
                      const SizedBox(height: 5,),
                      Text.rich(TextSpan(
                          text: "Already have an account? ",
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Login now',
                                style: const TextStyle(
                                    color: Colors.blue, fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()..onTap = () {
                                  nextScreen(context,const LoginPage());
                                })
                          ],
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)))
                    ],
                  ),

                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  register()async{
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading=true;
      });
      authService.registerUserWithEmailAndPassword(fullnameController.text, emailController.text, passwordController.text).then((value)async {
        if (value==true){
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(emailController.text);
          await HelperFunctions.saveUserNameSF(fullnameController.text);
          nextScreenReplace(context, HomePage());

        }else{
          showSnackbar(context, Colors.red, value);
          setState(() {
            _isLoading=false;
          });
        }
      });
    }
  }


}
