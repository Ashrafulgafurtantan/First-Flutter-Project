import 'dart:async';
import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:useallfeatures/models/user.dart';
import 'package:useallfeatures/pages/profile.dart';
import 'package:useallfeatures/pages/upload.dart';
import 'package:useallfeatures/progress.dart';
import 'package:useallfeatures/widgets/comments.dart';
import 'package:useallfeatures/widgets/custom_image.dart';
import 'package:useallfeatures/widgets/like_screen.dart';

import '../home.dart';

class Post extends StatefulWidget {

  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final dynamic likes;
  final String mediaUrl;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.likes,
    this.mediaUrl,
  });

  factory Post.fromDocument(DocumentSnapshot doc){
    return Post (
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      likes: doc['likes'],
      mediaUrl: doc['mediaUrl'],

    );
  }

  int getLikeCount(likes) {
    if (likes == null)
      return 0;
    int count = 0;
    likes.values.forEach((val){
      if(val==true)
        count++;
    });
    return count;
  }


  @override
  _PostState createState() => _PostState(
    postId:this.postId,
    ownerId:this.ownerId,
    username:this.username,
    location:this.location,
    description:this.description,
    likes:this.likes,
    mediaUrl:this.mediaUrl,
    likeCount: getLikeCount(this.likes),

  );
}

class _PostState extends State<Post> {

  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  Map likes;
  int likeCount;
  int commentCount=0;
  final String mediaUrl;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.likes,
    this.mediaUrl,
    this.likeCount,
  });
  bool isLiked=false,showHeart=false;

  @override
  void initState() {
    super.initState();
   // getComment();

  }
  getComment()async{
  QuerySnapshot snapshot=await  commentRef.document(postId).collection('userComments').getDocuments();
  setState(() {
    commentCount=  snapshot.documents.length;

  });

  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();


  }


  handleLikePost(){
    bool _isLike=likes[currentUser.id]==true;

    if(_isLike){
      firestorePost.document(ownerId).collection('userPosts')
          .document(postId).updateData({
        'likes.${currentUser.id}':false
      });
      dislikePostActivity();

      setState(() {
        likeCount-=1;
        isLiked=false;
        likes[currentUser.id]=false;
      });
    }
    else if(!_isLike){
      firestorePost.document(ownerId).collection('userPosts')
          .document(postId).updateData({
        'likes.${currentUser.id}':true
      });
      likePostActivity();
      setState(() {
        likeCount +=1;
        isLiked=true;
        likes[currentUser.id]=true;
        showHeart=true;
      });

      Timer(Duration(milliseconds : 500),(){
        setState(() {
          showHeart=false;
        });
      });
    }

  }
  likePostActivity(){
   // if(currentUser.id !=ownerId)
    {
      feedRef.document(ownerId).collection('feedItems').document(postId).setData({
      'type':'like',
      'username':currentUser.username,
      'userId':currentUser.id,
      'userProfileImg':currentUser.photoUrl,
      'postId':postId,
      'mediaUrl':mediaUrl,
      'timestamp':DateTime.now(),
      'postOwnerId':ownerId,
        'seen':false,

    });
    }


  }
  dislikePostActivity(){
      //if(currentUser.id !=ownerId)
      {
        feedRef.document(ownerId).collection('feedItems').document(postId).get().then((doc){

        if(doc.exists)
          doc.reference.delete();

      });
    }
  }

  showProfile(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (context){

      return Profile(profileId: ownerId,);
    }));

  }
  deletePostFromFirebase()async{
    await  firestorePost.document(ownerId).collection('userPosts').document(postId).get().then((doc){
        if(doc.exists)
          doc.reference.delete();

      });

   QuerySnapshot snapshot = await commentRef.document(postId).collection('comments').getDocuments();

    snapshot.documents.forEach((doc) {
      if(doc.exists)
        doc.reference.delete();
    });

    storageReference.child('post_$postId.jpg').delete();

    QuerySnapshot activitySnapshot=await feedRef
        .document(ownerId).collection('feedItems')
        .where('postId', isEqualTo: postId).getDocuments();

    activitySnapshot.documents.forEach((doc){
      if(doc.exists)
        doc.reference.delete();
    });
  }
  deletePostDialog(BuildContext parentContext){

  return showDialog(context: parentContext,
  builder: (context){
    return SimpleDialog(
      title: Center(
        child: Text('Post Deletion',
          style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),
        ),
      ),
      children: <Widget>[
        SimpleDialogOption(child: Text('Delete',
          style: TextStyle(color: Colors.red[900]),
        ),
          onPressed: (){
          Navigator.pop(context);
          deletePostFromFirebase();

          },),
        SimpleDialogOption(child: Text('Cancel'),onPressed: ()=>Navigator.pop(context),),

      ],
    );
    });

  }



  buildPostHeader(BuildContext context){
    return FutureBuilder(
      future: userRef.document(ownerId).get(),
      builder: (context,snapshot){
        if(!snapshot.hasData)
          return circularProgress();

        User user = User.fromDocument(snapshot.data);

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 25,
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
          ),
          title: GestureDetector(
            onTap: ()=>showProfile(context),
            child: Text(user.username,
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),

          ),
          subtitle: Text(description),
          trailing: currentUser.id !=ownerId ? Text(''): IconButton(icon: Icon(Icons.more_vert),
              onPressed: ()=>deletePostDialog(context)),
        );
      },
    );
  }

   buildPostImage(){
    return GestureDetector(
      onDoubleTap:handleLikePost,
      child: Stack(
        alignment: Alignment.center,

        children: <Widget>[
          cachedNetworkImage(mediaUrl),
          showHeart ? Animator<double>(
            tween: Tween(begin: 0.8, end: 1.4),
            cycles: 0,
            curve: Curves.elasticOut,
            builder: (context, animatorState, child ) => Transform.scale(
              scale: animatorState.value,
              child: Icon(Icons.favorite,size: 130,
                color: Colors.red.withOpacity(.5),
              ),
            ) ,):  Text('')

        ],
      ),
    );
  }

  comment(){
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return Comments(postId:postId,ownerId:ownerId,mediaUrl:mediaUrl);
    }));
  }
  like(){
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return LikeScreen(postId:postId,ownerId:ownerId);
    }));

  }

  buildPostFooter(){

    return Column(
      children: <Widget>[


        SizedBox(height: 3,),
        Padding(
          padding: const EdgeInsets.only(left: 5,bottom: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(child: Text(location,
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 1,
              ),
              ),),
            ],
          ),
        ),
        SizedBox(height: 4,),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(icon: Icon(isLiked?Icons.favorite:Icons.favorite_border,color: Colors.pink,),
              onPressed: handleLikePost,


            ),
            SizedBox(width: 10,),
            IconButton(icon: Icon(Icons.chat,color: Colors.teal[700],),
              onPressed: comment,
            ),

          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              child: Text('$likeCount likes',style: TextStyle(

                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),),
              onTap: like,
            ),
            SizedBox(width: 10,),
            GestureDetector(
              child: Text('$commentCount comments',style: TextStyle(

                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),),
              onTap: comment,
            ),
          ],

        ),

        Divider(
          height: 5,
          color: Colors.black26,
        ),
      ],
    );

  }


  @override
  Widget build(BuildContext context) {
    isLiked = likes[currentUser.id]==true;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(context),
        noImageUrl == mediaUrl ? Container() : buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}
