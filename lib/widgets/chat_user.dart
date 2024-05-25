import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattify/api/apis.dart';
import 'package:chattify/helper/date_util.dart';
import 'package:chattify/main.dart';
import 'package:chattify/screens/chat_screen.dart';
import 'package:chattify/widgets/chat_user_data.dart';
import 'package:chattify/widgets/message.dart';
import 'package:chattify/widgets/profiledialog.dart';
import 'package:flutter/material.dart';

class ChatUser extends StatefulWidget {
  final ChatUserData user;
  const ChatUser({super.key,required this.user});

  @override
  State<ChatUser> createState() => _ChatUserState();
}

class _ChatUserState extends State<ChatUser> {
 
  Messages? _messages;
   
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04,vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>ChatScreen(user:widget.user)));
        },
        child:  StreamBuilder(stream: APIs.getLastMessages(widget.user),
         builder:(context,snapshot){
           
           final data = snapshot.data?.docs;
           final list = data?.map((e) => Messages.fromJson(e.data())).toList() ?? [];
          if(list.isNotEmpty) _messages = list[0];     
          

          return ListTile(
        leading:InkWell(
          onTap: (){
            showDialog(context: context, builder: (_)=>Profiledialog(user: widget.user));
          },
          child: ClipOval(
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
        ),
          // leading: CircleAvatar(child: Icon(Icons.person),),
          title: Text(widget.user.name),
          subtitle: Text(_messages!=null? _messages!.type == Type.image? 'photo' :_messages!.msg: widget.user.about,maxLines: 1,),
          trailing:
          _messages== null ? null 
          : _messages!.read.isEmpty 
          && _messages!.
          fromid!=APIs.user.uid? 
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10)
            ),
          ):Text(DateUtil.getLastMessageTime(context: context, time:_messages!.sent),style: TextStyle(color: Colors.black),)
          // trailing: Text(
          //   '12:00pm',
          //   style: TextStyle(color: Colors.black),
          // ),
          );
         } ,)
      ),
    );
  }
}