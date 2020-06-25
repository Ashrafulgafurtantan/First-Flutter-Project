
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useallfeatures/header.dart';
import 'package:useallfeatures/home.dart';
import 'package:useallfeatures/progress.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
class Message extends StatefulWidget {

  final String profileId;
  final String username;
  Message({this.profileId,this.username});
  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {


  TextEditingController controller;

 // bool isFriend = false;
  bool isBlocked = false;

  addMessage()async{
    String msg  =controller.text;
    controller.clear();


    if(isBlocked == false) {
      friendRef.document ( currentUser.id ).updateData ( {
        'friends.${widget.profileId}':true

      } );
      friendRef.document ( widget.profileId ).updateData ( {
        'friends.${currentUser.id}':true

      });
      isBlocked = true;
    }
    String id =  messageRef.document(currentUser.id).collection(widget.profileId).document().documentID;
    await  messageRef.document(currentUser.id).collection(widget.profileId).document(id).setData({
      'receiverId':widget.profileId,
      'message': msg,
      'timestamp': DateTime.now(),
      'senderId': currentUser.id,
      'messageId':id,
      'seen': true,

    });

    await  messageRef.document(widget.profileId).collection(currentUser.id).document(id).setData({
      'receiverId':widget.profileId,
      'message': msg,
      'timestamp': DateTime.now(),
      'senderId': currentUser.id,
      'messageId':id,
      'seen':false,
    });
  }


  changeSeenValue(DocumentSnapshot doc,String docId)async{
    await messageRef.document(currentUser.id).collection(widget.profileId).document(docId).updateData({
      'seen':true,
    });
  }
  buildMessage(){
    return StreamBuilder<QuerySnapshot>(
      stream:messageRef.document(currentUser.id).collection(widget.profileId).orderBy('timestamp',descending: false).snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasData)
          return circularProgress();
        List<MessageBubble>messageList =[];
        snapshot.data.documents.reversed.forEach((doc){
          changeSeenValue(doc,doc.documentID);

          messageList.add(MessageBubble.fromDocument(doc));
        });

        return ListView(
          reverse: true,
          children: messageList,
        );

      },
    );
  }

  @override
  void initState() {
    controller=TextEditingController();
    super.initState();

    print('message');
   messageList.remove(widget.username);
    isFriendListed();
  }
  isFriendListed()async{
    Map  friendLists=Map();
    await friendRef.document(currentUser.id).get().then((doc){
      friendLists =   doc['friends'];
      if(friendLists.containsKey(widget.profileId)){

        friendLists[widget.profileId]?  setState(() {isBlocked = false;}): setState(() {isBlocked = true;});
      }
      else{
        setState(() {
          isBlocked = true;
        });
      }

    });
  }



  blockFriendFromFirebase()async{

 await   friendRef.document(currentUser.id).updateData({
      'friends.${widget.profileId}':false,
    });
 setState(() {
   isBlocked = true;
 });

 friendRef.document ( widget.profileId ).updateData ( {
   'friends.${currentUser.id}':false,

 });

  }
  unBlockFriendFromFirebase()async{
    await   friendRef.document(currentUser.id).updateData({
      'friends.${widget.profileId}':true,
    });
    setState(() {
      isBlocked = false;
    });

    friendRef.document ( widget.profileId ).updateData ( {
      'friends.${currentUser.id}':true,

    });

  }

  optionDialog(BuildContext parentContext){

    return showDialog(context: parentContext,
        builder: (context){
          return SimpleDialog(
            title: Center(
              child: Text(isBlocked ?  'UnBlock this Person': 'Block this Person?' ,
                style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),
              ),
            ),
            children: <Widget>[
              SimpleDialogOption(child: Text('Yes',
                style: TextStyle(color: Colors.red[900]),
              ),
                onPressed: (){

                  Navigator.pop(context);
                isBlocked ?  unBlockFriendFromFirebase() : blockFriendFromFirebase();

                },),
              SimpleDialogOption(child: Text('No'),onPressed: ()=>Navigator.pop(context),),

            ],
          );
        });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   //   appBar: header(context,title: widget.username,isTimeline: true,removeBackButton: true),
      appBar: AppBar(
        backgroundColor: Colors.teal,

        title:Center(
          child: Text(widget.username,
          style: TextStyle(
            fontFamily: 'Pacifico',
            color: Colors.white,
            fontSize: 25,
            letterSpacing: 2,
          ),
          ),
        ) ,
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.ellipsisV,color: Colors.white,),
            onPressed: ()=>optionDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [
              Theme.of(context).accentColor,
              Colors.white
            ],
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(child: buildMessage(),),
            Divider(height: 0, color: Colors.black26),
            // SizedBox(
            //   height: 50,
            Container(
              color: Colors.white,
              height: 50,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextField(

                  enabled: !isBlocked,
                  maxLines: 20,
                  controller: controller,
                  decoration: InputDecoration(
                    // contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                      suffixIcon:isBlocked ? IconButton( icon: Icon(Icons.announcement,color: Colors.teal),
                        onPressed: ()=>print('more options'),
                      ): IconButton(
                        icon: Icon(Icons.send,color: Colors.teal,),
                        onPressed:addMessage,
                      ),
                      border: InputBorder.none,
                      hintText: isBlocked ? 'You have Blocked ${widget.username}' : "enter your message",
                      hintStyle: TextStyle(
                          color: isBlocked ? Colors.red : Colors.teal[100],
                          fontWeight: isBlocked ? FontWeight.bold:FontWeight.normal,
                        fontFamily: isBlocked ? 'Romanesco': null ,
                        fontSize: isBlocked ? 20:null,
                        letterSpacing: isBlocked ? 2:null,



                      )
                  ),
                ),
              ),
            ),

          ],
        ),
      ),

    );
  }
}

class MessageBubble extends StatelessWidget {

  final String receiverId;
  final  String senderId;
  final String message;
  final Timestamp timestamp;
  final String messageId;
  final bool seen;

  MessageBubble({this.receiverId,this.senderId,this.message,this.timestamp,this.messageId,this.seen});

  factory MessageBubble.fromDocument(doc){
    return MessageBubble(
      receiverId: doc['receiverId'],
      senderId: doc['senderId'],
      message: doc['message'],
      timestamp: doc['timestamp'],
      messageId: doc['messageId'],
      seen: doc['seen'],

    );
  }

  deleteMessage()async{
    double timeLaps =( (DateTime.now().millisecondsSinceEpoch)-(timestamp.millisecondsSinceEpoch)).toDouble();
    timeLaps = timeLaps/1000;
    print(timeLaps);

    if(timeLaps<600){
      await messageRef.document ( senderId ).collection ( receiverId).document(messageId).get().then((value) {
        if(value.exists)
          value.reference.delete();

      });

      await messageRef.document ( receiverId ).collection ( senderId).document(messageId).get().then((value) {
        if(value.exists)
          value.reference.delete();

      });
    }
  }

  toggleOptions(BuildContext parentContext){
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
                deleteMessage();
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
          crossAxisAlignment: currentUser.id ==senderId? CrossAxisAlignment.end:CrossAxisAlignment.start,
          children: <Widget>[

            Material(
              elevation: 5,
              color:currentUser.id ==senderId? Colors.teal:Colors.white,
              borderRadius: currentUser.id ==senderId? BorderRadius.only(topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),bottomRight: Radius.circular(30)
              ):BorderRadius.only(topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),bottomRight: Radius.circular(30)
              ),

              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                child: Text(message,
                  style: TextStyle(
                //    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color:currentUser.id ==senderId? Colors.white: Colors.teal,
                  ),
                ),
              ),
            ),
            //DateFormat.jm().format(time.toDate()),
            Padding(
              padding: const EdgeInsets.only( left: 8.0,right: 8,top: 3,bottom: 8),
              child: Text(DateFormat.jm().format(timestamp.toDate()),
                style: TextStyle(
                    fontSize: 8
                ),
              ),
            ),


          ],
        ),
      ),
    ) ;
  }
}


/*

  addMessage()async{
    print(docPath);

    String msg  =controller.text;
    if(!controller.text.trim().isEmpty){

      await messageRef.document('${currentUser.id}_${widget.profileId}').get().then((doc){
        if(doc.exists){
          String id = messageRef.document('${currentUser.id}_${widget.profileId}').collection('userMessages').document().documentID;
          messageRef.document('${currentUser.id}_${widget.profileId}').collection('userMessages').document(id).setData({
            'receiverId':widget.profileId,
            'message': msg,
            'timestamp': DateTime.now(),
            'senderId': currentUser.id,
            'messageId':id,

          });

        }
        else{
           messageRef.document('${widget.profileId}_${currentUser.id}').get().then((doc){
             // if(doc.exists){
                String id = messageRef.document('${widget.profileId}_${currentUser.id}').collection('userMessages').document().documentID;
                messageRef.document('${widget.profileId}_${currentUser.id}').collection('userMessages').document(id).setData({
                  'receiverId':widget.profileId,
                  'message': msg,
                  'timestamp': DateTime.now(),
                  'senderId': currentUser.id,
                  'messageId':id,

                });

             // }

          });
        }
      });
    }
    controller.clear();
  }

*/

/* addMessage()async{
    if(!controller.text.trim().isEmpty){
      String id = messageRef.document ( currentUser.id ).collection ( 'userMessages').document(widget.profileId )
          .collection('messageList').document().documentID;

      messageRef.document ( currentUser.id ).collection ( 'userMessages').document(widget.profileId )
          .collection('messageList').document(id).setData ( {
        'receiverId':widget.profileId,
        'message': controller.text,
        'timestamp': DateTime.now(),
        'senderId': currentUser.id,
        'messageId':id,
      } );

      messageRef.document ( widget.profileId ).collection ( 'userMessages').document(currentUser.id )
          .collection('messageList').document(id).setData ( {
        'receiverId':widget.profileId,
        'message': controller.text,
        'timestamp': DateTime.now(),
        'senderId': currentUser.id,
        'messageId':id,
      } );

    }

    controller.clear();
  }
*/


/*
  getDocumentPath()async{
    await messageRef.document('${currentUser.id}_${widget.profileId}').get().then((doc) {
      if(doc.exists){
        setState(() {
          docPath = '${currentUser.id}_${widget.profileId}';
        });
      }
      else{
        setState(() {
          docPath = '${widget.profileId}_${currentUser.id}';
        });
      }
    });

  }
*/