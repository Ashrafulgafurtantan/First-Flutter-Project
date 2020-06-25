import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:useallfeatures/widgets/message.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

class ChatListViewItem  extends StatelessWidget {
  final String image;
  final String userId;
  final String name;
  final String lastMessage;
  final Timestamp time;
  final bool isOwner;
  final bool hasUnreadMessage;
  final int newMesssageCount;
   ChatListViewItem({

    this.image,
     this.userId,
    this.name,
   this.lastMessage,
    this.time,
     this.isOwner,
    this.hasUnreadMessage,
    this.newMesssageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                flex: 10,
                child: ListTile(
                  title: Text(
                    name,
                    style: TextStyle(fontSize: 22,
                    fontFamily: 'Signatra',
                      letterSpacing: 2,
                      color: Colors.grey
                    ),
                  ),
                  subtitle: Text(
                    lastMessage,

                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12,
                    fontWeight:isOwner? FontWeight.normal: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(image),
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                       // isOwner? "": timeago.format(time.toDate()),
                        isOwner? "":DateFormat.jm().format(time.toDate()),

                        style: TextStyle(fontSize: 12),
                      ),
                      hasUnreadMessage
                  //  isOwner? false:true
                   // !isOwner
                          ? Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        height: 18,
                        width: 18,
                        decoration: BoxDecoration(
                            color: Color(0xFFFF8C00),
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0),
                            )),
                        child: Center(
                            child: Text(
                             // '3',
                              newMesssageCount.toString(),
                              style: TextStyle(fontSize: 11),
                            )),
                      )
                          : SizedBox()
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Message(profileId: userId,username: name,),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Divider(
            endIndent: 12.0,
            indent: 12.0,
            height: 0,
          ),
        ],
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Archive',
          color: Colors.blue,
          icon: Icons.archive,
          onTap: () {},
        ),
        IconSlideAction(
          caption: 'Share',
          color: Colors.indigo,
          icon: Icons.share,
          onTap: () {},
        ),
      ],
    );
  }
}
