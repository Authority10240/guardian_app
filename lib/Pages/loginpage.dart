import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:guardian_app/Pages/Entacom_home.dart';
import 'package:guardian_app/SQL_Models/child_model.dart';
import 'package:guardian_app/SQL_Models/contact_model.dart';
import 'package:guardian_app/SQL_Models/message_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:guardian_app/BackEnd/DBHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget{
  @override
  _LoginPageSate createState()=>_LoginPageSate();
}
class _LoginPageSate extends State<LoginPage>{
  String _email;
  String   _password;

  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();


  //google sign
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  final formkey=new GlobalKey<FormState>();
  checkFields(){
    final form=formkey.currentState;
    if(form.validate()){
      form.save();
      return true;
    }
    return false;
  }



  LoginUser(){
    if (checkFields()){
      FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password)
          .then((user){
        print("signed in as ${user.uid}");
        Navigator.of(context).pushReplacementNamed('/userpage');
      }).catchError((e){
        print(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Material(
      color: Colors.cyan[600],
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
            height: 150, //220
            width: 150, //110
            margin: EdgeInsets.only(top: 50.0),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/logo.png'),
                    fit: BoxFit.contain),

              borderRadius: BorderRadius.only
                (
                  bottomLeft: Radius.circular(500.0),
                  bottomRight: Radius.circular(500.0)
              ),

           ),
          ),

         Center(
           child : Text(
            "Entacom Guardian",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontFamily: "Sans",
              fontSize: 35.0,
            ),
          ),
         ),
          Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width - 200,
            child: Center(
              child: Padding(

                padding: const EdgeInsets.all(28.0),
                child: Center(
                    child: Form(

                      key: formkey,
                      child: Center(
                        child: ListView(
                          shrinkWrap: true,
                          children: <Widget>[

                            _input("required email",false,"Email",'Enter your Email',(value) => _email = value),
                            SizedBox(width: 20.0,height: 20.0,),
                            _input("required password",true,"Password",'Password',(value) => _password = value),
              new Padding(padding: EdgeInsets.all(8.0),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                            children: <Widget>[
                              Expanded(
                                child: OutlineButton(
                                  child: Text("Sign In"),
                                  onPressed:LoginUser
                                ),
                                flex: 1,
                              ),
                              SizedBox(height: 18.0,width: 18.0,),

                              SizedBox(height: 18.0,width: 18.0,),
                              Expanded(
                                flex: 1,
                                child: OutlineButton(
                                  color: Colors.white,
                                    //child: Text("login with google"),
                                   // child: ImageIcon(AssetImage("images/google1.png"),semanticLabel: "login",),
                                    child: Image(image: AssetImage("assets/google1.png"),height:28.0,fit: BoxFit.fitHeight),
                                    onPressed: () async{
                                      await _signIn().then(( FirebaseUser user){
                                       if(user.isEmailVerified) {
                                         Navigator.pushReplacement(context,
                                             MaterialPageRoute(
                                                 builder: (context) =>
                                                     EntacomHome()));
                                       }
                                      }).catchError((e){
                                          e.toString();
                                      });
                                    }),
                              )

                            ],
                      ),
                      SizedBox(height: 15.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Don't Have An Account?",
                            style: TextStyle(fontFamily: 'Montserrat'),
                          ),
                          SizedBox(width: 5.0),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: Text(
                              'Create New Account.',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Montserrat',
                                  ),

                            ),
                          )
                        ],
                      ),
                      OutlineButton(
                          child: Text("Sign Up"),
                          color: Colors.white,

                          onPressed: (){
                            Navigator.of(context).pushNamed('/signup');
                          }),
                      OutlineButton(
                          child: Text("Help"),
                          onPressed: (){
                            Navigator.of(context).pushNamed('/help');
                          })
                    ],

                  ),

                ),
              ),),

                          ],

                        ),
                      ),
                    )
                ),
              ),
            ),
          ),
        ],
      ) ,
    );
  }
  Widget _input(String validation,bool ,String label,String hint, save ){
    return new TextFormField(
      decoration: InputDecoration(
          hintText: hint,
          fillColor: Colors.white,
          labelText: label,
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0)
          ),
      ),
      obscureText: bool,
      validator: (value)=>
      value.isEmpty ? validation: null,
      onSaved: save ,

    );

  }


PopUpNotification(String){

}

Future<FirebaseUser>_signIn()async{

  final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final FirebaseUser user = await _auth.signInWithCredential(credential);
  setVirginity();
  return user;

}

setVirginity() async{
    SharedPreferences virginity = await SharedPreferences.getInstance();
    virginity.setBool('Virginity', true);
}



}

