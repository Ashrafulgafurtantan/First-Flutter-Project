import 'dart:async';

import 'package:flutter/material.dart';
import 'package:useallfeatures/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey=GlobalKey<FormState>();
  final _scaffold=GlobalKey<ScaffoldState>();

  String username;

  submit(){
    final form=_formKey.currentState;
    if(form.validate()){
      SnackBar snackBar=SnackBar(content: Text('Welcome $username'));
      _scaffold.currentState.showSnackBar(snackBar);
      print(username);
      Timer(Duration(seconds: 2),()async{
      await  Navigator.pop(context,username);
      });
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
     // backgroundColor: Colors.white,
      appBar: header(context,title: 'Create Account',removeBackButton:true),
      body: ListView(
        children: <Widget>[
          Container(
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
                    child: Form(
                      key: _formKey,
                      autovalidate: true,
                      child: TextFormField(

                        validator: (val){
                          if(val.trim().length<3||val.trim().isEmpty){
                            return 'Too short';

                          }
                          else if(val.trim().length>13)
                            return 'Too long';
                          else
                            return null;
                        },

                     //  onSaved: (val)=> username=val,
                       onChanged: (val){
                          username=val;
                       },
                      //  autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(
                            fontSize: 15,
                          ),
                          hintText: 'At least 3 characters',
                          border: OutlineInputBorder(),

                        ),

                      )

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
                  onTap: submit,

                )

              ],
            ),
          )
        ],
      ),

    );
  }
}
