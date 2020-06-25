import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:useallfeatures/header.dart';
import 'package:useallfeatures/home.dart';
import 'package:useallfeatures/progress.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:io';

class Comments extends StatefulWidget {

  final String postId;
 final  String ownerId;
  final String mediaUrl;
  Comments({this.postId,this.ownerId,this.mediaUrl});
  @override
  _CommentsState createState() => _CommentsState(
    postId: this.postId,
    ownerId: this.ownerId,
    mediaUrl: this.mediaUrl,

  );
}

class _CommentsState extends State<Comments> {

  final String postId;
  final  String ownerId;
  final String mediaUrl;
  _CommentsState({this.postId,this.ownerId,this.mediaUrl});


  TextEditingController commentController=TextEditingController();
  buildComment(){

    return StreamBuilder<QuerySnapshot>(
      stream:commentRef.document ( postId ).collection ( 'userComments' ).orderBy('timestamp',descending: false).snapshots() ,
      builder: (context,snapshot){
        if(!snapshot.hasData)
          return circularProgress();
        List<Comment>commentList =[];
        snapshot.data.documents.reversed.forEach((doc){
          commentList.add(Comment.fromDocument(doc));
        });

        return ListView(
          reverse: true,
          children: commentList,
        );

      },
    );

  }
  addComment() async{
      String id =await commentRef.document ( postId ).collection ( 'userComments' ).document().documentID;

      commentRef.document ( postId ).collection ( 'userComments' ).document(id).setData ( {
        'username': currentUser.username,
        'comment': commentController.text,
        'timestamp': DateTime.now(),
        'avatarUrl': currentUser.photoUrl,
        'userId': currentUser.id,
        'commentId':id,
        'postId':postId,

      } );


  // if(currentUser.id !=ownerId)
    {
      feedRef.document(ownerId).collection('feedItems').add({
        'type':'comment',
        'commentData':commentController.text,
        'username':currentUser.username,
        'userId':currentUser.id,
        'userProfileImg':currentUser.photoUrl,
        'postId':postId,
        'mediaUrl':mediaUrl,
        'timestamp':DateTime.now(),
        'postOwnerId':ownerId,
        'seen': false,


      });
    }


    commentController.clear();
    setState(() {

    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,title: 'Comments'),
      body: Column(

        children: <Widget>[
          Expanded(child: buildComment(),),
          ListTile(

            title: TextFormField(
              controller:commentController ,
              decoration: InputDecoration(
                labelText: 'Write something...',
              ),

            ),
            trailing: OutlineButton(onPressed: addComment,
              child: Text('post'),
              borderSide: BorderSide.none,
            ),
          )
        ],
      )
    );
    
  }
}

class Comment extends StatelessWidget {

  final String username;
  final  String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;
  final String commentId;
  final String postId;


  Comment({this.username,this.userId,this.comment,this.timestamp,this.avatarUrl,this.commentId,this.postId});

  factory Comment.fromDocument(doc){
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      comment: doc['comment'],
    timestamp: doc['timestamp'],
      avatarUrl: doc['avatarUrl'],
      commentId: doc['commentId'],
      postId: doc['postId'],
    );
  }

  deleteComment()async{
   await commentRef.document ( postId ).collection ( 'userComments' ).document(commentId).get().then((value) {
      if(value.exists)
        value.reference.delete();

    });
  }

  toggleOptions(parentContext){
    return showDialog(context: parentContext,
      builder: (context){
        return SimpleDialog(
          title: Text('Options'),
          children: <Widget>[
            SimpleDialogOption(child: Text('Delete',
            style: TextStyle(
              color: Colors.red[900],
              fontSize: 20,
            ),
            ),
              onPressed: (){
              Navigator.pop(context);
                deleteComment();
              },
            ),
            SimpleDialogOption(child: Text('Cancel'),
              onPressed: ()=>Navigator.pop(context),
            ),

          ],
        );

      },
    );

  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onLongPress: ()=>toggleOptions(context),
      child: Padding(
        padding: const EdgeInsets.only(left:8.0,right: 8.0),
        child: Column(
          crossAxisAlignment: currentUser.id ==userId? CrossAxisAlignment.end:CrossAxisAlignment.start,
          children: <Widget>[
            Text(username,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Material(
              elevation: 5,
              color:currentUser.id ==userId? Colors.blue:Colors.white,
              borderRadius: currentUser.id ==userId? BorderRadius.only(topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),bottomRight: Radius.circular(30)
              ):BorderRadius.only(topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),bottomRight: Radius.circular(30)
              ),

              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                child: Text(comment,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Text(timeago.format(timestamp.toDate()),
              style: TextStyle(
                  fontSize: 8
              ),
            ),

          ],
        ),
      ),
    ) ;
  }
}

/* ListTile(
          onLongPress: ()=>toggleOptions(context),
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
            backgroundColor: Colors.grey,
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),

        ),*/