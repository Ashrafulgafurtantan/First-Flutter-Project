import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:useallfeatures/widgets/custom_image.dart';
import 'package:useallfeatures/widgets/post.dart';
import 'package:useallfeatures/widgets/post_screen.dart';
class PostTile extends StatelessWidget {
  final Post post;
  PostTile({this.post});

  showPost(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (context){

      return  PostScreen(postId: post.postId,ownerId:  post.ownerId,);
    }));

  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: cachedNetworkImage(post.mediaUrl) ,
      onTap: ()=>showPost(context),

    );
  }
}
