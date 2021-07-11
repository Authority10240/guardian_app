import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardian_app/Pages/loginpage.dart';
import 'package:guardian_app/Pages/Entacom_home.dart';
import 'package:guardian_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardian_app/SQL_Models/child_model.dart';
import 'package:guardian_app/SQL_Models/contact_model.dart';
import 'package:guardian_app/SQL_Models/message_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:guardian_app/BackEnd/DBHelper.dart';
import 'package:guardian_app/UIX/CustomListView.dart';
import 'package:guardian_app/SQL_Models/child_model.dart';

/// Run first apps open
void main() {
  runApp(myApp());
}

/// Set orienttation
class myApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /// To set orientation always portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    ///Set color status bar
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent, //or set color with: Color(0xFF0000FF)
    ));
    return new MaterialApp(
      title: "+Up",
      theme: ThemeData(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          primaryColorLight: Colors.cyan,
          primaryColorBrightness: Brightness.light,
          primaryColor: Colors.cyan),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      /// Move splash screen to ChoseLogin Layout
      /// Routes
      routes: <String, WidgetBuilder>{
        "login": (BuildContext context) => new LoginPage(),
      },
    );
  }
}

/// Component UI
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();

}

/// Component UI
class _SplashScreenState extends  State<SplashScreen> {
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
  String schoolName, teacherID, subField, subDepartment, subID, studentNumber;

  @override
  /// Setting duration in splash screen
  startTime() async {
    return new Timer(Duration(milliseconds: 4500), NavigatorPage);
  }
  /// To navigate layout change
  void NavigatorPage() {
    listenToMessages();
    choosePage();
  }
  /// Declare startTime to InitState
  @override
  void initState() {
    super.initState();
    startTime();
  }
  /// Code Create UI Splash Screen
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyanAccent,
      body: Container(
        /// Set Background image in splash screen layout (Click to open code)
        decoration: BoxDecoration(
        ),
        child: Container(
          /// Set gradient black in image splash screen (Click to open code)
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0.3),
                    Color.fromRGBO(0, 0, 0, 0.4)
                  ],
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter)),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 30.0),
                    ),
                    /// Text header "Welcome To" (Click to open code)
                    Hero(
                      tag: "Logo",
                      child: Image.asset(
                        'assets/logo.png',
                        width: 120.0,
                        height: 120.0,

                      ),

                    ),
                    Text(
                      "Entacom Guardian",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontFamily: "Sans",
                        fontSize: 35.0,
                      ),
                    ),
                    /// Animation text Treva Shop to choose Login with Hero Animation (Click to open code)
                    Hero(
                      tag: "+Up",
                      child: Text(
                        "Always With You",
                        style: TextStyle(
                          fontFamily: 'Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 11.0,
                          letterSpacing: 0.4,
                          color: Colors.white,
                        ),
                      ),
                    ),


                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }




  Future<bool> checkVirginity() async {
    SharedPreferences virginity = await SharedPreferences.getInstance();

    return virginity.getBool('Virginity');
  }

  void choosePage() async{
    if (await checkVirginity() == true){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EntacomHome()));
    }else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }


  Future listenToMessages() async {
    // get information from the student table
    List<ChildInformaiton> childInfo = await MyApp.dbHelper.getChildrenList();
    //loop through all the information to get individual studet details
    for (int i = 0; i < childInfo.length; i++) {
      // get the subject for each individual unique students
      List<ContactInformation> contactInfo = await MyApp.dbHelper.getContactList
        (childInfo[i].STUDENT_NUMBER);
      //loop through all the each subject of each student.
      for (int j = 0; j < contactInfo.length; j++) {
        //gether the required information from the relevant tables


        schoolName = childInfo[i].SCHOOL_ID;
        teacherID = contactInfo[i].TEACHER_ID;
        subField = contactInfo[i].COURSE_ID;
        subDepartment = contactInfo[i].DEPARTMENT_ID;
        subID = contactInfo[i].SUBJECT_ID;
        studentNumber = childInfo[i].STUDENT_NUMBER;


        //start listening to messages from firebase with the struture

        databaseReference.child(schoolName).child("SMESSAGES")
            .child(teacherID).child(contactInfo[j].SCHOLAR_YEAR).child(subField)
            .child(contactInfo[j].SUBJECT_ID).child(contactInfo[j].SET).child('GROUPED').onChildAdded.listen((event) {
          var val = event.snapshot.value;
          messageInformation messageinformation = new messageInformation
              .blank();
          //populate with data from firebase;
          messageinformation.ARRIVAL_DATE = val['ARRIVAL_DATE'];
          messageinformation.ATTACHMENT_ID = val['ATTACHMENT_ID'];
          messageinformation.DEVICE_ID = val['DEVICE_ID'];
          messageinformation.EXTENTION = val['sExtentionID'];
          messageinformation.NEW_MESSAGE = val['NEW_MESSAGE'];
          messageinformation.MESSAGE_CONTENT = val['MESSAGE_CONTENT'];
          messageinformation.MESSAGE_HEADING = val['MESSAGE_HEADING'];
          messageinformation.MESSAGE_ID = val['MESSAGE_ID'];
          // messageinformation.MESSAGE_PRIORITY = val['id'];
          messageinformation.SUBJECT_ID = val['SUBJECT_ID'];
          messageinformation.MESSAGE_PRIORITY = val['MESSAGE_PRIORITY'];
          messageinformation.STUDENT_NUMBER = childInfo[i].STUDENT_NUMBER;
          //insert into database;

          //insert into database;
          MyApp.dbHelper.insertNewMessage(messageinformation);
          // insert the new message flag to all message categories.



        });
      }
    }
  }
}
