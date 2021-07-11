



import 'dart:ui';

import 'package:flutter/material.dart';
import 'file:///C:/Users/Freedom/Downloads/Entacom%20Apps/Principal/entacom_principal/lib/Pages/SplashScreen.dart';
import 'package:guardian_app/SQL_Models/year_Model.dart';
import 'package:guardian_app/main.dart';
import "package:sqflite/sqflite.dart";
import 'package:guardian_app/BackEnd/DBHelper.dart';
import 'package:guardian_app/SQL_Models/child_model.dart';
import 'package:guardian_app/Pages/add_QR_screen.dart';
import 'package:guardian_app/Pages/Subject_List.dart';
import 'package:guardian_app/Pages/Entacom_home.dart';
class yearScreen extends StatefulWidget{
 ChildInformaiton childInformaiton;

 yearScreen(this.childInformaiton);

  @override
  State<StatefulWidget> createState() {

    // TODO: implement createState
    return new yearScreenState(childInformaiton);
  }

}

class yearScreenState extends State<yearScreen>{
  ChildInformaiton ci;

  yearScreenState(this.ci);

  int count = 0;
  List<YearInformation> yearInfo   ;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(yearInfo == null){
      yearInfo = List();

      updateListVIew();
    }


    return Scaffold(
      appBar: AppBar(
      title:
      Text('${ci.getSTUDENT_NAME()}\'s Attended Years'),
      centerTitle: true,
      leading: FlatButton(
        onPressed: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EntacomHome()));
        },
        child: Icon(Icons.arrow_back, color: Colors.white,),
      ),),
    floatingActionButton: FloatingActionButton.extended(onPressed: (){
      MyApp.studentView = 0;
      Navigator.pushReplacement(context,
          MaterialPageRoute(
              builder: (context) =>
                  QRCodeAddScreen(ci)));

    }, label: Text('Add Subject'),backgroundColor: Colors.cyan,

    ),
    body:
      WillPopScope(
        onWillPop: (){
          return    Navigator.push(context, MaterialPageRoute(builder: (context) => EntacomHome()));
        },
        child: ListView.builder(
          itemCount: count,

          itemBuilder: (context,i)=> new Card(

            color: Colors.white
            , child:

          new ListTile(

            leading: new CircleAvatar(
              foregroundColor: Theme.of(context).primaryColor,
              backgroundColor: Colors.cyan,
              child: Text((yearInfo[i].SCHOLAR_YEAR[2]) + yearInfo[i].SCHOLAR_YEAR[3],
                style: TextStyle(color: Colors.white),),),
            trailing: Icon(Icons.email, color:  getYearColor(yearInfo[i]),),
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(yearInfo[i].SCHOLAR_YEAR,
                  style : new TextStyle( fontSize: 20.0),
                ),
              ],
            ),
            onTap: (){
              MyApp.studentView = 1;
              Navigator.pushReplacement(context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Subject_List(ci,yearInfo[i])));


            },
          ),
          ),
        ),
      )
    );
  }

  updateListVIew() {
    final Future<Database> dbFuture = MyApp.dbHelper.initDB();
    dbFuture.then((database) {
      Future<List<YearInformation>> childrenListFuture = MyApp.dbHelper
          .getYearList(ci.STUDENT_NUMBER);
      childrenListFuture.then((yearList) {
        setState(() {
          this.yearInfo = yearList;
          this.count = yearList.length;
          filterYear();
        });
      });
    });
  }

 Color  getYearColor(YearInformation yi){
    Color color = Colors.grey;
    if(yi.NEW_MESSAGE == 'Y'){
      color = Colors.amber;
    }
    return color;
  }

  filterYear(){
    bool newMessage = false;

    for(int i = 0 ; i< yearInfo.length; i++){
      if(yearInfo[i].NEW_MESSAGE == 'Y')
        newMessage = true;
    }

    if(!newMessage){
      MyApp.dbHelper.updateNewMessageStudentTable(ci.getSTUDENT_NUMBER(), 'N');
    }
  }

}