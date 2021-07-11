

import 'package:flutter/material.dart';
import 'package:guardian_app/SQL_Models/child_model.dart';
import 'package:guardian_app/SQL_Models/contact_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:guardian_app/BackEnd/DBHelper.dart';
import 'package:guardian_app/UIX/Dialogs.dart';


class Set_Selector extends StatefulWidget {
  @override
  ChildInformaiton ci ;
  ContactInformation conInf;
  List<String> set;

  Set_Selector(this.ci, this.conInf);

  _Set_SelectorState createState() => _Set_SelectorState(ci,conInf);
}

class _Set_SelectorState extends State<Set_Selector> {
  ChildInformaiton ci;
  List<String> set;
  List<String> employee = List();
  ContactInformation contInf ;
  _Set_SelectorState(this.ci, this.contInf);
  DatabaseReference ref;
  DBHelper dbHelper = DBHelper();
  Dialogs dialogs = Dialogs();




  @override
  Widget build(BuildContext context) {

    // TODO: implement build

    if (set == null){
      set = List();
      UpdateListView();
    }
    return Scaffold(appBar:
    AppBar(centerTitle: true,
      title: Text('SET',style: TextStyle(color: Colors.white),),),
      body: ListView.builder(itemCount: set.length,itemBuilder: ( context , pos) =>
      new Column(
        children: <Widget>[
          GestureDetector( child: ListTile(leading:
          new CircleAvatar(
            child: Text( set[pos ],
              style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.cyan,),title: Text('SET '+set[pos]),),
            onTap: (){

              contInf.SET = set[pos];


              dialogs.ConfirmSubject(context, dbHelper, 'Add Subject', 'Add:'
                  '\nGrade ' + '\'${contInf.COURSE_ID}\''
                  '\nSubject ' + '\'${contInf.SUBJECT_ID}\''
                  '\nSet: ' '\'${contInf.SET}\''
                  '\nTo:' + '\'${ci.getSTUDENT_NAME() + ' ' + ci.getSTUDENT_SURNAAME()}', ci, contInf);



            },),

          Divider(height: 10,)
        ],
      )),);
  }

  UpdateListView(){
    ref = FirebaseDatabase.instance.reference();
    ref.child(ci.getSCHOOL_ID()).child(DateTime.now().year.toString())
        .child('GRADE').child(contInf.COURSE_ID).child('SUBJECTS')
        .child(contInf.SUBJECT_ID).child('TEACHER').child(contInf.TEACHER_ID)
        .child('SET_NUMBER').onChildAdded.listen((event){
      var val = event.snapshot.value;
      String set_number = val['SET_NUMBER'];

      setState(() {
        set.add(set_number);

      });

    });

  }
}
