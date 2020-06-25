import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:useallfeatures/header.dart';
import 'package:useallfeatures/home.dart';
import 'package:useallfeatures/models/user.dart';
import 'package:useallfeatures/progress.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController=TextEditingController();
  TextEditingController bioController=TextEditingController();
  bool _validDisplayName=true;
  bool _validBio=true;
  User user;
  bool isLoading = false;


  displayNameField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text('Display Name',
            style: TextStyle(
                color: Colors.grey
            ),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            errorText: _validDisplayName ? null:'Invalid Input',
            hintText: 'Must be greater than 2 char',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        )
      ],
    );

  }
  bioField(){
    return   Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text('Bio ',
            style: TextStyle(
                color: Colors.grey
            ),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            suffixIcon: Icon(Icons.mode_edit,color: Colors.grey,),
            errorText: _validBio ? null:'Invalid Input',
            hintText: 'Not more than 100 char',

            hintStyle: TextStyle(color: Colors.grey),
          ),
        )
      ],
    );

  }

  updateAll()async{

    if(bioController.text.trim().length > 100 && displayNameController.text.trim().length < 3){
     setState(() {
       _validDisplayName = false;
       _validBio = false;

     });
    }
    else if(displayNameController.text.trim().isEmpty || displayNameController.text.trim().length < 3){
      setState(() {
        _validDisplayName = false;
        _validBio=true;

      });
    }
    else{
      setState(() {
        _validDisplayName = true;
        _validBio=true;

      });
      userRef.document(currentUser.id).updateData({
        'bio':bioController.text,
        'displayname': displayNameController.text,

      });

      SnackBar snackBar = SnackBar(content: Text('Update successfull'),
    //  duration: Duration(seconds: 1 ),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
     // Navigator.pop(context);

    }
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }
  getUser()async{
    setState(() {
      isLoading=true;
    });

    DocumentSnapshot doc=await userRef.document(currentUser.id).get();
    user=User.fromDocument(doc);
    displayNameController.text = user.displayname;
    bioController.text = user.bio;

    setState(() {
      isLoading=false;
    });
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,

        title: Center(
          child: Text('Edit Profile',
            style: TextStyle(
              fontSize: 22,
              color: Colors.black,
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back,color: Colors.red),
            onPressed: (){
              Navigator.pop(context);

            },
          )
        ],
      ),
      body: isLoading ?  shimmer() :ListView(
        children: <Widget>[
          Column(
            //    mainAxisAlignment: MainAxisAlignment.center,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top:16,bottom: 8),
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(currentUser.photoUrl),
                  backgroundColor: Colors.grey,
                  radius: 50,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    displayNameField(),
                    bioField(),
                  ],
                ),

              ),
              FlatButton.icon(
                icon: Icon(Icons.cloud_upload,color: Colors.white,),
                color: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                onPressed: updateAll,
                label: Text('Update',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 7,),

              FlatButton.icon(
                icon: Icon(Icons.cancel,size: 20,color: Colors.white,),
                color: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                onPressed: (){

                  googleSignIn.signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return Home();
                  }));

                },
                label: Text('Log out',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            ],

          ),
        ],

      ),

    );
  }
}
