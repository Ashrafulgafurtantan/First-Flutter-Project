import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:useallfeatures/header.dart';
import 'package:useallfeatures/home.dart';
import 'package:useallfeatures/models/user.dart';
import 'package:useallfeatures/pages/search.dart';
import 'package:useallfeatures/progress.dart';

class LikeScreen extends StatefulWidget {
  final String postId;
  final String ownerId;
  LikeScreen({this.postId,this.ownerId});

  @override
  _LikeScreenState createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
  Map likes;
  List<SearchResult>searchResults=[];


  @override
  void initState() {
    super.initState();
    testFunction();
  }

  testFunction()async{
    Stream<DocumentSnapshot>     documentSnapshot;
    List<SearchResult>sr=[];

    DocumentSnapshot  snapshot =await  firestorePost.document (widget.ownerId).collection ('userPosts').document(widget.postId).get();
    likes = snapshot.data['likes'];
    print(likes.length);
    likes.forEach((key, value) async{
      print(key);
      if(value==true){
        documentSnapshot =await userRef.document(key).snapshots();
        documentSnapshot.forEach((doc) {
          User user =User.fromDocument(doc);
          SearchResult searchResult=SearchResult(user: user);
          sr.add(searchResult);
          print(user.username);
          setState(() {
            searchResults=sr;
          });
        });
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,title: 'Likes'),
      body: searchResults==null? circularProgress():ListView(
        children: searchResults,
      ),
    );
  }
}
