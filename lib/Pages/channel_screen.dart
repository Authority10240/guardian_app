import 'package:flutter/material.dart';
import 'package:guardian_app/SQL_Models/contact_model.dart';


class ContactScreen  extends StatefulWidget {
  @override
  _State createState() => _State();
}


class _State extends State<ContactScreen> {
  ContactInformation contactInformation;
  List<ContactInformation> contactList = new List<ContactInformation>();
  int count = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subject'),

      ),
      body: ListView.builder(itemCount: count,
        itemBuilder: (BuildContext context , int positions){
        return Card(
          color: Colors.white,
          elevation: 7.0,
          child: ListTile(
            onTap: (){

            },
            leading: CircleAvatar(
              child: Icon(Icons.mail_outline),
            ),
            title: Text(contactList[positions].SUBJECT_ID ),
            subtitle: Text(contactList[positions].TEACHER_NAME),
              trailing: Icon(Icons.mail, color: Colors.amber,),
          ),
        );
      },),
    );
  }
}
