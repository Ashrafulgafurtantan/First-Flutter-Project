

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
import '../header.dart';
import '../home.dart';

class CreateAccount extends StatefulWidget {
  GoogleSignInAccount user;
  CreateAccount({this.user});
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String userName;
  TextEditingController controller;
  bool _validate=true;
//  final  _formKey=GlobalKey<FormState>();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userName =null;
    controller=TextEditingController();
  }
  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      appBar: header(parentContext,title:'Set Up Your Account',removeBackButton:true),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('Create a user Name',
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.black

                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: controller,
                    maxLength: 13,
                    textAlign: TextAlign.center,
                    onChanged: (val){
                      userName=val;
                      if(val.length<3 || val.length>13 ){
                        setState(() {
                          _validate = false;
                        });
                      }else{
                        setState(() {
                          _validate = true;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade900,
                      errorText: _validate ? null : 'Invalid input',
                      hintText: 'Must be at least 3 char',
                      labelText: 'UserName',
                      labelStyle: TextStyle(fontSize: 15,color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        //  borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: ()async{
                    FocusScope.of(context).unfocus();
                    print('hello 1');

                   if(userName != null && _validate == true){

                     print('hello 2');

                     await  userRef.document(widget.user.id).setData({
                       'id': widget.user.id,
                       'name':userName,
                       'photo': widget.user.photoUrl,
                       'displayName':widget.user.displayName,
                       'email':widget.user.email,
                       'bio':'',
                       'timestamp':DateTime.now(),

                     });
                     print('hello 3');
                     await followersRef.document(widget.user.id)
                         .collection('userFollowers').document(widget.user.id).setData({});
                     print('hello 4');
                   Navigator.pop(parentContext,userName);
                   }else{
                     setState(() {
                       _validate = false;
                     });
                   }
                    print('hello 5');
                  },
                  child: Container(
                    height: 50,
                    width: 350,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(
                        child: Text('Submit',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}


/*
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:useallfeatures/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {

  final _scaffold=GlobalKey<ScaffoldState>();
  TextEditingController  controller;
  bool validator = false;
  String username;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller =TextEditingController();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,

      appBar: header(context,title: 'Create Account',removeBackButton:false),
      body: ListView(
        children: <Widget>[
          Flexible(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 60,
                  ),
                  Text('Create a user name',
                    style: TextStyle(
                      fontSize: 30,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      child: TextField(

                        controller: controller,
                       onChanged: (val){
                          username=val;
                         if(val.length<3 || val.length>12){
                           setState(() {
                             validator = true;
                           });
                         }else{
                           setState(() {
                             validator = false;
                           });
                         }
                       },
                       autofocus: true,
                        decoration: InputDecoration(
                          errorText: validator ? "Invalid Input":null,
                          labelText: 'Username',
                          labelStyle: TextStyle(
                            fontSize: 15,
                          ),
                          hintText: 'At least 3 characters',
                          border: OutlineInputBorder(),

                        ),

                      ),
                    ),
                  ),
                  GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      height: 50,
                      width: 200,
                      child: Center(child: Text('Submit',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),

                      )),
                    ),
                    onTap: (){
                      if( !validator){
*/
                     /*   SnackBar snackBar=SnackBar(content: Text('Welcome $username'));
                        _scaffold.currentState.showSnackBar(snackBar);

                         Timer(Duration(seconds: 1),()async{
                            Navigator.pop(context,username);
                        });
                        Navigator.pop(context,username);
                      }else{
                        setState(() {
                          validator = true;
                        });

                      }
                    },

                  )

                ],
              ),
            ),
          )
        ],
      ),

    );
  }
}
*/