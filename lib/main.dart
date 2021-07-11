import 'package:flutter/material.dart';
import 'dart:isolate';
import 'file:///C:/Users/Freedom/Downloads/Entacom%20Apps/Principal/entacom_principal/lib/Pages/SplashScreen.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';


import 'package:guardian_app/SQL_Models/child_model.dart';
import 'package:guardian_app/SQL_Models/contact_model.dart';
import 'package:guardian_app/SQL_Models/message_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:guardian_app/BackEnd/DBHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:guardian_app/Pages/Entacom_home.dart';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';






void printHello() {
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  print("[$now] Hello, world! isolate=${isolateId} function='$printHello'");

  // additional to the default code that was provided to with the example of how thwe alarm service works
  ////////////////////////////////////////////

}





main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    final int helloAlarmID = 0;
    await AndroidAlarmManager.initialize();

  }catch(e){
    e.toString();
  }

  try{

    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }catch(e){
    e.toString();
  }


  runApp(MyApp());
}

class MyApp extends StatefulWidget{
    static int studentView = 1;
    static DBHelper dbHelper = DBHelper();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return MyAppState();
  }


//        databaseReference = FirebaseDatabase.getInstance().getReference().child(cs.getSchoolID()).child("SMESSAGES").child(cs.getDeviceId()).child(cs.getField()).child(cs.getDepartment()).child(cs.getSubjectID());





}

class MyAppState extends State<MyApp> {






  @override
  void initState() {
    // TODO: implement initState
    PopUpNotification();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/entacom': (context) => EntacomHome(),

      },
      title: 'Entacom',
      theme: new ThemeData(
        primaryColor: Colors.cyan[600],
        accentColor: Colors.white,

      ),
      home: new SplashScreen(),
    );
  }
  // opens the application to another page when the notification is clicked
  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new EntacomHome()),
    );
  }

  Future onDidReceiveLocalNotification(int number,String payload, String str2, String str3) async {

  }


  PopUpNotification() async {
   SharedPreferences sp = await SharedPreferences.getInstance(); // initialise the sharedpreference variable

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    //initialise the notifiaction variable

    ////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////
    //initialising the notification widget
    //////////////////////////////////////////////////////////////////////////
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    //////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////




    int minute , hour;

    if(sp.getInt('Hour') == null){
      // timer has not been set yet.
    }else {
      minute = sp.getInt('Minute');
      hour = sp.getInt('Hour');


      var time = new Time(hour, minute, 0);

      var androidPlatformChannelSpecifics =
      new AndroidNotificationDetails('Entacom Reminder Notification',
          'Entacom', 'Time to check your childrens work');
      var iOSPlatformChannelSpecifics =
      new IOSNotificationDetails();
      var platformChannelSpecifics = new NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.showDailyAtTime(
          0,
          'Entcaom Notification',
          'Check Entacom for school notifications',
          time,
          platformChannelSpecifics);
    }
  }
}