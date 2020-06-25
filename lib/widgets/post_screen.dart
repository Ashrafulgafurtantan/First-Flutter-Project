import 'package:flutter/material.dart';
import 'package:useallfeatures/header.dart';
import 'package:useallfeatures/home.dart';
import 'package:useallfeatures/progress.dart';
import 'package:useallfeatures/widgets/post.dart';

class PostScreen extends StatefulWidget {

 final String postId;
  final String ownerId;
  PostScreen({this.postId,this.ownerId});
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firestorePost.document(widget.ownerId).collection('userPosts').document(widget.postId).get(),
        builder: (context,snapshot){
          if(!snapshot.hasData)
            return circularProgress();
         
          Post post = Post.fromDocument(snapshot.data);
          return Scaffold(
           // appBar: header(context,removeBackButton: true,title: post.location),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          );
        },

      ) ;
    
  }
}
