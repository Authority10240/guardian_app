import 'package:flutter/material.dart';
import 'package:guardian_app/SQL_Models/child_model.dart';
import 'package:guardian_app/SQL_Models/contact_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rxdart/rxdart.dart';
import 'Subject_Selector.dart';

class Grade_Selector extends StatefulWidget {
  @override
  ChildInformaiton ci ;

  Grade_Selector(this.ci);

  _Grade_SelectorState createState() => _Grade_SelectorState(ci);
}

class _Grade_SelectorState extends State<Grade_Selector> {
  ChildInformaiton ci;
  List<String> Grade ;
  ContactInformation contInf ;
  _Grade_SelectorState(this.ci);
  DatabaseReference ref;



  @override
  Widget build(BuildContext context) {

    // TODO: implement build

    if (Grade == null){
      Grade = List();
      contInf = ContactInformation.blank();
      UpdateListView();
    }
    return Scaffold(appBar:
    AppBar(centerTitle: true,
      title: Text('Child Grade',style: TextStyle(color: Colors.white),),),
      body: ListView.builder(itemCount: Grade.length,itemBuilder: ( context , pos) =>
      new Column(
        children: <Widget>[
          GestureDetector( child: ListTile(leading:
          new CircleAvatar(
            child: Text( Grade[pos],
              style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.cyan,),title: Text('Grade ' + Grade[pos]),),
            onTap: (){
              String grade = Grade[pos];
              contInf.COURSE_ID = grade;
              contInf.DEPARTMENT_ID = grade;
              Navigator.push(context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Subject_Selector(ci,contInf)));


            },),

          Divider(height: 10,)
        ],
      )),);
  }

  UpdateListView(){
    ref = FirebaseDatabase.instance.reference();
    ref.child(ci.getSCHOOL_ID()).child(DateTime.now().year.toString())
        .child('GRADE').onChildAdded.listen((event){
      var val = event.snapshot.value;
      setState(() {
        Grade.add(event.snapshot.key);
      });

    });

  }
}
