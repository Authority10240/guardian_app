

import 'package:flutter/material.dart';
import 'package:guardian_app/SQL_Models/child_model.dart';
import 'package:guardian_app/SQL_Models/contact_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:guardian_app/SQL_Models/year_Model.dart';
import 'package:guardian_app/main.dart';
import 'Teacher_Selector.dart';
import 'package:guardian_app/BackEnd/DBHelper.dart';
import 'package:firebase_database/firebase_database.dart';
import "package:sqflite/sqflite.dart";
import 'package:guardian_app/Pages/years_screen.dart';
import 'MessageView.dart';
class Subject_List extends StatefulWidget {
  @override
  ChildInformaiton ci ;
  ContactInformation conInf;
  YearInformation yi;
  Subject_List(this.ci, this.yi);

  _Subject_ListState createState() => _Subject_ListState(ci, yi);
}

class _Subject_ListState extends State<Subject_List> {
  ChildInformaiton ci;
  YearInformation yi;
  List<ContactInformation> Subject ;
  ContactInformation contInf ;
  _Subject_ListState(this.ci, this.yi);
  DatabaseReference ref;




  @override
  Widget build(BuildContext context) {

    // TODO: implement build

    if (Subject == null){
      Subject = List();

      UpdateListView();
    }
    return Scaffold(appBar:
    AppBar(centerTitle: true,
      title: Text('${ci.getSTUDENT_NAME()}\'s Subjects',style: TextStyle(color: Colors.white),),
      leading: FlatButton(
        onPressed: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => new yearScreen(ci)));
        },
        child:Icon(Icons.arrow_back, color: Colors.white,)
      )),

      body:WillPopScope(
        onWillPop: (){
          return Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => new yearScreen(ci)));

        },child:  ListView.builder(itemCount: Subject.length,itemBuilder: ( context , pos) =>
      new Column(
        children: <Widget>[
          GestureDetector( child: Card(child: ListTile(
            leading:
            new CircleAvatar(
              child: Text( Subject[pos].SUBJECT_ID[0],
                style: TextStyle(color: Colors.white),),
              backgroundColor: Colors.cyan,)
            ,title: Text(Subject[pos].SUBJECT_ID),
            subtitle: Text('Grade:${Subject[pos].COURSE_ID}  SET:${Subject[pos].SET}'),
            trailing: Icon(Icons.email, color: getSubjectColor(Subject[pos]),),), ),

            onLongPress:(){
              OptionPanel(context,'Delete Subject?',
                  'Would you like to delete subject: ${Subject[pos].SUBJECT_ID}',
                  Subject[pos],yi,ci) ;
            },

            onTap: (){
              if (MyApp.studentView == 0){
                contInf= Subject[pos];
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Teacher_Selector(ci,contInf)));
              }else{
                contInf= Subject[pos];
                Navigator.pushReplacement(context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MessageView(ci,contInf, yi)));
              }




            },),

          Divider(height: 10,)
        ],
      )),
      ),);
  }

  UpdateListView(){
    final Future<Database> dbFuture = MyApp.dbHelper.initDB();
    dbFuture.then((database) {
      Future<List<ContactInformation>> childrenListFuture = MyApp.dbHelper
          .getContactList(ci.STUDENT_NUMBER);
      childrenListFuture.then((yearList) {
        setState(() {
          this.Subject = yearList;
          filterSubjects();
        });
      });
    });

  }
Color getSubjectColor(ContactInformation ci){
    Color color = Colors.grey;
    if(ci.NEW_MESSAGE == 'Y'){
      color = Colors.amber;
    }
    return color;
}

filterSubjects(){
    bool newMessage = false;

    for(int i = 0 ; i< Subject.length; i++){
      if(Subject[i].NEW_MESSAGE == 'Y')
        newMessage = true;

    }
    if(!newMessage){
      MyApp.dbHelper.updateNewMessageYearTable(ci.getSTUDENT_NUMBER(), 'N');
    }
}

  OptionPanel(BuildContext context,  String title,
      String description,
       ContactInformation contactInformation , YearInformation yearInformation, ChildInformaiton chil) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[

                  FlatButton(onPressed: (){
                    MyApp.dbHelper.deleteSubject(chil.STUDENT_NUMBER,contactInformation.SUBJECT_ID , yearInformation.SCHOLAR_YEAR);
                    Subject.remove(contactInformation);
                    setState(() {

                    });
                    Navigator.pop(context);

                  },
                    child: Text('Delete Subject'),
                    hoverColor: Colors.white,
                    color: Colors.red,
                  ),
                  FlatButton(onPressed: (){
                   Navigator.pop(context);
                  },
                    child: Text('Cancel'),
                    hoverColor: Colors.white,
                    color: Colors.cyan,
                  ),

                ],
              ),
            ),

          );
        }
    );
  }
}
