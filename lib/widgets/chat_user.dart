import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattify/main.dart';
import 'package:chattify/screens/chat_screen.dart';
import 'package:chattify/widgets/chat_user_data.dart';
import 'package:flutter/material.dart';

class ChatUser extends StatefulWidget {
  final ChatUserData user;
  const ChatUser({super.key,required this.user});

  @override
  State<ChatUser> createState() => _ChatUserState();
}

class _ChatUserState extends State<ChatUser> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04,vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>ChatScreen(user:widget.user)));
        },
        child: ListTile(
        leading:ClipOval(
          child: ClipRect(
            child: CachedNetworkImage(
              width: mq.height * .055,
              height: mq.height * .055,
            imageUrl: widget.user.image,
            // placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => CircleAvatar(child: Icon(Icons.person),)
                 ),
          ),
        ),
          // leading: CircleAvatar(child: Icon(Icons.person),),
          title: Text(widget.user.name),
          subtitle: Text(widget.user.about,maxLines: 1,),
          trailing: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10)
            ),
          ),
          // trailing: Text(
          //   '12:00pm',
          //   style: TextStyle(color: Colors.black),
          // ),
        ),
      ),
    );
  }
}