import 'dart:async';
import 'dart:core';
import 'dart:developer';
import 'package:guardian_app/SQL_Models/child_model.dart';
import 'package:guardian_app/SQL_Models/school_model.dart';
import 'package:guardian_app/SQL_Models/year_Model.dart';
import 'package:guardian_app/SQL_Models/message_model.dart';
import 'package:guardian_app/SQL_Models/contact_model.dart';
import 'package:path/path.dart';
import "package:sqflite/sqflite.dart";
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
class DBHelper {

  /*
   * this is information of the CHILD TABLE
   */
  final String CHILD_TABLE = 'CHILD_TABLE';
  final String STUDENT_NUMBER = 'STUDENT_NUMBER';
  final String STUDENT_NAME = 'STUDENT_NAME';
  final String STUDENT_SURNAAME = 'STUDENT_SURNAME';
  final String SCHOOL_ID = 'SCHOOL_ID'
  ;

  /*
 *this is information for the school table
  */
  final String SCHOOL_TABLE = 'SCHOOL_TABLE';
  final String SCHOOL_NAME = 'SCHOOL_NAME';
  final String SCHOOL_LOCATION = 'SCHOOL_LOCATION';
  final String SCHOOL_EMAIL = 'SCHOOL_EMAIL';
  final String SCHOOL_CONTACTS = 'SCHOOL_CONTACTS';
  final String SCHOOL_PRINCIPAL = 'SCHOOL_PRINCIPAL';

  /*
   * this is information of the message table
   */
  final String MESSAGE_TABLE = 'MESSAGE_TABLE';
  final String ARRIVAL_DATE = 'ARRIVAL_DATE';
  final String DEVICE_ID = 'DEVICE_ID';
  final String MESSAGE_CONTENT = 'MESSAGE_CONTENT';
  final String MESSAGE_HEADING = 'MESSAGE_HEADING';
  final String MESSAGE_ID = 'MESSAGE_ID';
  final String SUBJECT_ID = 'SUBJECT_ID';
  final String ATTACHMENT_ID = 'ATTACHEMENT_ID';
  final String EXTENTION = 'EXTENTION';
  final String NEW_MESSAGE = 'NEW_MESSAGE';
  final String MESSAGE_PRIORITY = 'MESSAGE_PRIORITY';

  // include student id into this table

  // this is for the subject table
  // include student device ID into this table
  final String TEACHER_ID = 'TEACHER_ID';
  final String SUBJECT_TABLE = 'SUBJECT_TABLE';
  final String DEPARTMENT_ID = "DEPARTMENT_ID";
  final String COURSE_ID = 'COURSE_ID';
  final String SET_ID = 'SET_ID';

  //include subject ID in this table
  final String TEACHER_NAME = 'TEACHER_NAME';

  //this is a table for the year a student enters school
  final String YEAR_TABLE = 'YEAR_TABLE';
  final String SCHOLAR_YEAR = 'SCHOLAR_YEAR';

  //include student_Id in this table


  static Database db_instance;

  Future<Database> get db async {
    if (db_instance == null) {
      db_instance = await initDB();
    }

    return db_instance;
  }


  Future<Database> initDB() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'Entacom.db');
    var db = await openDatabase(path, version: 1, onCreate: onCreateFunc);

    return db;
  }


  void onCreateFunc(Database db, int version) async {
    //child table to store different chidren
    await db.execute(
        'CREATE TABLE $CHILD_TABLE( id  INTEGER  , '
            '$STUDENT_NUMBER TEXT PRIMARY KEY, $STUDENT_NAME TEXT , $STUDENT_SURNAAME TEXT , $SCHOOL_ID TEXT , $NEW_MESSAGE TEXT);');

    //messages table to store messages
    await db.execute(
        'CREATE TABLE $MESSAGE_TABLE( '
            '$ARRIVAL_DATE TEXT, $STUDENT_NUMBER TEXT, $DEVICE_ID TEXT , $MESSAGE_CONTENT TEXT , '
            '$MESSAGE_HEADING TEXT, $MESSAGE_ID TEXT , $SUBJECT_ID TEXT, $ATTACHMENT_ID TEXT , '
            '$EXTENTION TEXT , $NEW_MESSAGE TEXT ,  $SCHOLAR_YEAR TEXT, '
            'PRIMARY KEY($MESSAGE_ID, $SUBJECT_ID,$DEVICE_ID,$STUDENT_NUMBER) );');

    //subject table to store subject information
    await db.execute(
        'CREATE TABLE $SUBJECT_TABLE ($TEACHER_ID  TEXT,'
            '$STUDENT_NUMBER TEXT, $COURSE_ID TEXT , $SUBJECT_ID TEXT,'
            ' $TEACHER_NAME TEXT , $SCHOLAR_YEAR TEXT, $SET_ID TEXT , $NEW_MESSAGE TEXT); ');

    //year table to store years
    await db.execute(
        'CREATE TABLE $YEAR_TABLE ( $SCHOLAR_YEAR TEXT ,'
            ' $STUDENT_NUMBER TEXT,$NEW_MESSAGE TEXT, PRIMARY KEY($SCHOLAR_YEAR ,$STUDENT_NUMBER));');
    // school table to store schools offline
    await db.execute(
        'CREATE TABLE $SCHOOL_TABLE ( id INTEGER PRIMARY KEY AUTOINCREMENT,'
            ' $SCHOOL_NAME TEXT , $SCHOOL_LOCATION TEXT , $SCHOOL_CONTACTS TEXT ,'
            ' $SCHOOL_EMAIL TEXT , $SCHOOL_PRINCIPAL TEXT ,$NEW_MESSAGE TEXT);');
  }


////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////BEGINNING OF STUDENT INFORMATION TABLE METHODS//////////
  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  /**
   * Add New Student
   * Adds new student to the database of students with all required information namely:
   * STUDENT_NUMBER
   * STUDENT_NAME
   * STUDENT_SURNAME
   * SCHOOL_ID
   */
  Future<int> addNewStudent(ChildInformaiton childInformation) async {
    Database database = await db;
    childInformation.id = await getChildCount() + 1;

     return db_instance.insert(CHILD_TABLE, childInformation.toMap());


  }

  /**
   * updates a particular record on the child database
   */
  Future<int> updateChid(ChildInformaiton childInfo) async {


        return db_instance.update(
       CHILD_TABLE, childInfo.toMap(), where: '$STUDENT_NUMBER = ?',
       whereArgs: [childInfo.STUDENT_NUMBER]);


  }

  Future<int> deleteChild(ChildInformaiton childInfo) async {


       return db_instance.delete(
       CHILD_TABLE, where: '$STUDENT_NUMBER = ?',
       whereArgs: [childInfo.STUDENT_NUMBER]);

  }

  /**
   * get the count of students
   *
   */

  Future<int> getChildCount() async {
      List<Map<String, dynamic>> y = await db_instance.rawQuery(
          'SELECT COUNT(*) FROM $CHILD_TABLE'
      );
    return Sqflite.firstIntValue(y);
  }

  /**
   * checks if a particular student has already been added
   */
  Future<bool> CheckUser(ChildInformaiton childInfo) async {
    bool present = false;
    List<Map<String, dynamic>> x = await db_instance.rawQuery(
        'SELECT COUNT(*) FROM $CHILD_TABLE WHERE $STUDENT_NUMBER = ? AND $SCHOOL_ID = ?',
        [childInfo.STUDENT_NUMBER, childInfo.SCHOOL_ID]);
    if (x.isNotEmpty) {
      present = true;
    }
    return present;
  }


  /**
   * Gets the students whom have been registered on the device and all required information namely
   * STUDENT_NUMBER
   * STUDENT_NAME
   * STUDENT_SURNAME
   * SCHOOL_ID
   *
   * returns Futur<list<ChildInformation>>
   **/
  Future<List<Map<String, dynamic>>> getStudent() async {

    var result = await db_instance.query(CHILD_TABLE);
    return result;
  }

  /**
   * Helps converts the students list from a Map to a List for the list view
   *
   * from Map<String, dynamic> >> List<ChildInformation>
   */
  Future<List<ChildInformaiton>> getChildrenList() async {
    db_instance = await db;
    var childMapList = await getStudent();

    List<ChildInformaiton> childInfo = List<ChildInformaiton>();

    for (int i = 0; i < childMapList.length; i++) {
      childInfo.add(ChildInformaiton.fromMapObject(childMapList[i]));
    }

    return childInfo;
  }

  //////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
/////////////////////////////END OF STUDENT INFORMATION TABLE METHODS//////////
///////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
/////////////////BEGINNING OF SCHOOL INFORMATION TABLE METOHDS//////////////////
////////////////////////////////////////////////////////////////////////////////

  /**
   * set all the schools that have registered on the admin portal and their information namely
   * SCHOOL_NAME
   * SCHOOL_LOCATION
   * SCHOOL_CONTACTS
   * SCHOOL_EMAIL
   * SCHOOL_PRINCIPAL
   */
  void addNewSchool(SchoolInformation schoolinformation) async {

    String query = 'INSERT INTO $SCHOOL_TABLE VALUES(\'${schoolinformation
        .getSCHOOL_NAME()}\''
        ',\'${schoolinformation.SCHOOL_LOCATION}\',\'${schoolinformation
        .SCHOOL_CONTACTS}\''
        ',\'${schoolinformation.SCHOOL_EMAIL}\' ,\' ${schoolinformation
        .SCHOOL_PRINCIPAL}\')';

        db_instance.rawInsert(query);

  }

  /**
   * get all the school registered on the database from the server and saves them as a map file
   * SCHOOL_NAME
   * SCHOOL_LOCATION
   * SCHOOL_CONTACTS
   * SCHOOL_EMAIL
   * SCHOOL_PRINCIPAL
   */

  Future<List<Map<String, dynamic>>> getSchools() async {

    var result = await db_instance.query(SCHOOL_TABLE, orderBy: SCHOOL_NAME);
    return result;
  }

  /**
   * helps convert the school list obejct from Map to List for listview
   * from Map<String, dynamic> to List<SchoolInformation>
   */

  Future<List<SchoolInformation>> getSchoolList() async {
    var childMapList = await getSchools();

    List<SchoolInformation> childInfo = List<SchoolInformation>();

    for (int i = 0; i < childMapList.length; i++) {
      childInfo.add(SchoolInformation.fromMapObject(childMapList[i]));
    }

    return childInfo;
  }

//////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
/////////////////////////////END OF SCHOOL INFORMATION TABLE METHODS//////////
///////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
/////////////////BEGINNING OF YEAR TABLE METHODS//////////////////////////////
//////////////////////////////////////////////////////////////////////////////

                       /**
   * adds years for subject scanned
   */

  void addNewYear(ChildInformaiton childInformaiton,ContactInformation ci) async {

    String query = 'INSERT INTO $YEAR_TABLE VALUES('
        '\'${DateTime.now().year.toString()}\',\'${childInformaiton
        .STUDENT_NUMBER.trim()}\',\'N\')';


        await db_instance.rawInsert(query);


  }

  /**
   * gets the years per each student attendance
   */
  Future<List<Map<String, dynamic>>> getYears(String studentNumber) async {

    var result = await db_instance.query(
        YEAR_TABLE, where: '$STUDENT_NUMBER = ?',
        whereArgs: [studentNumber],
        orderBy: SCHOLAR_YEAR);
    return result;
  }

  /**
   * gets the years in the form of a yearlist object, which is used to populate material objects.
   */
  Future<List<YearInformation>> getYearList(String studentNumber) async {
    var childMapList = await getYears(studentNumber);

    List<YearInformation> yearInfo = List<YearInformation>();

    for (int i = 0; i < childMapList.length; i++) {
      yearInfo.add(YearInformation.fromMapObject(childMapList[i]));
    }

    return yearInfo;
  }


///////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
/////////////////////END OF YEAF INFORMATION LIST///////////////////////////////
////////////////////////////////////////////////////////////////////////////////

//------------------------------------END---------------------------------------

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
///////////BEGINNING OF MESSAGE TABLE METHODS///////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

  void insertNewMessage( messageInformation messageinformation) async {

    String query = 'INSERT INTO $MESSAGE_TABLE VALUES('
        '\'${messageinformation.ARRIVAL_DATE}\''
        ',\'${messageinformation.STUDENT_NUMBER}\','
        '\'${messageinformation.DEVICE_ID}\','
        '\'${messageinformation.MESSAGE_CONTENT}\''
        ',\'${messageinformation.MESSAGE_HEADING}\' ,'
        '\'${messageinformation.MESSAGE_ID}\','
        '\'${messageinformation.SUBJECT_ID}\','
        '\'${messageinformation.ATTACHMENT_ID}\','
        '\'${messageinformation.EXTENTION}\','
        '\'${messageinformation.NEW_MESSAGE}\','
        '\'${new DateTime.now().year.toString()}\')';

    try {
      int response = await db_instance.rawInsert(query);
      if (response > 0) {
        updateNewMessageStudentTable(messageinformation.STUDENT_NUMBER, 'Y');
        updateNewMessageSubjectTable(
            messageinformation.STUDENT_NUMBER, messageinformation.SUBJECT_ID,
            'Y');
        updateNewMessageYearTable(messageinformation.STUDENT_NUMBER, 'Y');
      }
    }catch(e){
    log(e.toString());
    }
  }

  updateNewMessage(ContactInformation contactInformation , YearInformation yearInformation , ChildInformaiton ci) async{

    Map<String, dynamic> row = {
      NEW_MESSAGE : 'N'
    };


     return  db_instance.update(MESSAGE_TABLE, row ,where: '$SUBJECT_ID = ? AND $SCHOLAR_YEAR = ? AND $STUDENT_NUMBER = ? '
          , whereArgs: [contactInformation.SUBJECT_ID, yearInformation.SCHOLAR_YEAR, ci.STUDENT_NUMBER]);



  }
  // gets message count from database based on the criteria of the student and counts
  //for any new messages.get

  Future<int> getStudentNewMessageCount(ChildInformaiton ci)async{



         Future <List<Map<String,dynamic>>> y = db_instance.rawQuery(
      'SELECT COUNT(*) FROM $MESSAGE_TABLE '
      'WHERE $STUDENT_NUMBER = ${ci.STUDENT_NUMBER} AND'
      ' $NEW_MESSAGE = "Y"');

          return Sqflite.firstIntValue(await y);


  }

  //gets new message count from database based on the criteria of the student and the year.get
  Future<int> getStudentYearNewMessageCount(ChildInformaiton ci , String Years)async{



      List<Map<String,dynamic>> y = await db_instance.rawQuery(
      'SELECT COUNT(*) FROM $MESSAGE_TABLE '
      'WHERE $STUDENT_NUMBER = ${ci.STUDENT_NUMBER} AND'
      ' $NEW_MESSAGE = "Y" AND $SCHOLAR_YEAR = $Years');
      int result = Sqflite.firstIntValue(y);
      return result;


  }

  ///////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////
  //gets new message count from database bassed on the student, year and subject.
  Future<int> getStudentYearSubjectNewMessageCount(ChildInformaiton ci , String Years , ContactInformation contInfo)async{


      List<Map<String,dynamic>> y = await db_instance.rawQuery(
          'SELECT COUNT(*) FROM $MESSAGE_TABLE '
              'WHERE $STUDENT_NUMBER = ${ci.STUDENT_NUMBER} AND'
              ' $NEW_MESSAGE = "Y" AND $SCHOLAR_YEAR = $Years AND $SUBJECT_ID '
              '= ${contInfo.SUBJECT_ID} ');

      int result = Sqflite.firstIntValue(y);
      return result;


  }

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  //Gets all messages from database based on student, year and subject.

  Future<List<Map<String, dynamic>>> getAllContactMessages(ChildInformaiton ci, ContactInformation contactInformation, YearInformation yi ) async{

    var result = await db_instance.query(MESSAGE_TABLE, where: STUDENT_NUMBER
        + ' = ? AND ' + SCHOLAR_YEAR + ' = ? AND  $SUBJECT_ID = ?' ,
      whereArgs: [ci.STUDENT_NUMBER, yi.SCHOLAR_YEAR,contactInformation.SUBJECT_ID]);
    return result;


  }

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  Future<List<messageInformation>> getMessageList(ContactInformation contInfo , YearInformation yi , ChildInformaiton ci  ) async{
    var messageMap = await getAllContactMessages(ci, contInfo, yi);

    List<messageInformation> messageList =  List<messageInformation>();

    for(int i = 0 ; i < messageMap.length;i++){
      messageList.add(messageInformation.fromMapObject(messageMap[i]));
    }

    return messageList;
  }

////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  ////////////////////////BEGINNING OF CONTACT INFORMATION/////////////////////
  /////////////////////////////////////////////////////////////////////////////

  Future<List<Map<String, dynamic>>> getContacts(String StudentNumber) async{

    var result = await db_instance.query(SUBJECT_TABLE, where: STUDENT_NUMBER
        + ' = ? AND ' + SCHOLAR_YEAR + ' = ?' ,whereArgs: [StudentNumber,
    new DateTime.now().year.toString()],);

    return result;
  }


  Future<List<ContactInformation>> getContactList(String studentNumber ) async{
    var contactMap = await getContacts(studentNumber);

    List<ContactInformation> contactList =  List<ContactInformation>();

    for(int i = 0 ; i < contactMap.length;i++){
      contactList.add(ContactInformation.fromMapObject(contactMap[i]));
    }

   return contactList;
  }

  void insertContact(ChildInformaiton childinfo,ContactInformation continfo) async{


    String query = 'INSERT INTO $SUBJECT_TABLE VALUES('
    '\'${continfo.TEACHER_ID}\''
    ',\'${childinfo.getSTUDENT_NUMBER()}\''
    ',\'${continfo.COURSE_ID}\''
    ',\'${continfo.SUBJECT_ID}\''
    ',\'${continfo.TEACHER_NAME}\''
    ',\'${DateTime.now().year.toString()}\''
    ',\'${continfo.SET}\',\'N\')';

       db_instance.rawInsert(query);

  }
  /*
    final String MESSAGE_TABLE = 'MESSAGE_TABLE';
  final String ARRIVAL_DATE = 'ARRIVAL_DATE';
  final String DEVICE_ID = 'DEVICE_ID';
  final String MESSAGE_CONTENT = 'MESSAGE_CONTENT';
  final String MESSAGE_HEADING = 'MESSAGE_HEADING';
  final String MESSAGE_ID = 'MESSAGE_ID';
  final String SUBJECT_ID = 'SUBJECT_ID';
  final String ATTACHMENT_ID = 'ATTACHEMENT_ID';
  final String EXTENTION = 'EXTENTION';
  final String NEW_MESSAGE = 'NEW_MESSAGE';
  final String MESSAGE_PRIORITY = 'MESSAGE_PRIORITY';
   */

  Future<int> getChildNewMessageCount(String studentNumber ) async {

    List<Map<String, dynamic>> x = await db_instance.rawQuery(
        'SELECT COUNT(*) FROM $MESSAGE_TABLE WHERE $STUDENT_NUMBER = $studentNumber ');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  /*
  These are new message markers. these methods will set a new message marker for all new messages on the system and the entire hiarachy
  namely Student information \ Subject information and year information
   */
 updateNewMessageStudentTable(String studentNumber, String opt) async {



      await db_instance.update(
         CHILD_TABLE, {'$NEW_MESSAGE': opt}, where: '$STUDENT_NUMBER = ?',
         whereArgs: [studentNumber]);

 }
  updateNewMessageYearTable(String studentNumber ,String opt) async{



      await db_instance.update(YEAR_TABLE,{'$NEW_MESSAGE': opt}
      ,where: '$STUDENT_NUMBER = ? AND $SCHOLAR_YEAR = ?' ,
          whereArgs: [studentNumber,DateTime.now().year.toString()]);

  }

  updateNewMessageSubjectTable(String studentNumber , String subjectID,String opt) async {



      await db_instance.update(SUBJECT_TABLE, {'$NEW_MESSAGE': opt},
          where: '$STUDENT_NUMBER = ? AND $SUBJECT_ID = ? AND $SCHOLAR_YEAR = ? ',
          whereArgs: [studentNumber, subjectID, DateTime
              .now()
              .year
              .toString()
          ]);

  }
deleteSubject(String studentnumber, String subjcectId , String year) async{

      db_instance.delete(SUBJECT_TABLE,
          where: '$SUBJECT_ID = ? AND $STUDENT_NUMBER = ? AND $SCHOLAR_YEAR = ?' ,
          whereArgs: [subjcectId,studentnumber,year]);

}

  }