import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattify/api/apis.dart';
import 'package:chattify/main.dart';
import 'package:chattify/screens/homepage.dart';
import 'package:chattify/widgets/chat_user.dart';
import 'package:chattify/widgets/chat_user_data.dart';
import 'package:chattify/widgets/message.dart';
import 'package:chattify/widgets/message_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatScreen extends StatefulWidget {

  final ChatUserData user;
  const ChatScreen({super.key,required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
 List<Messages> _list = [];

 final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.tealAccent.shade700));
    return SafeArea(
      child: 
      Scaffold(
           appBar: AppBar(
            backgroundColor: Colors.tealAccent.shade700,
            automaticallyImplyLeading: false,
            flexibleSpace: _appbar(),
           ),
           
           body: Column(
             children: [
              Expanded(
                child: StreamBuilder(

                 stream: APIs.getAllMessages(widget.user),
                 builder: (context, snapshot) {
                 switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator(),);
                        
                  case ConnectionState.active:
                  case ConnectionState.done:
                     // TODO: Handle this case.
                        
                     
                
                             
                  final data = snapshot.data?.docs;
                 
                  _list = data?.map((e) => Messages.fromJson(e.data())).toList() ?? [];
               
                if(_list.isNotEmpty){
                 return ListView.builder(
                  itemCount: _list.length,
                  padding: EdgeInsets.only(top: mq.height * .01),
                  itemBuilder: (context, index) {
                       return MessageCard(message: _list[index],);
                    // return Text("Name:${list[index]}");
                  },
                );
                             }
                             else{
                return Center(
                  child: Text('say Hi👋',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
                  
                          ),
                );
                             }
                 }
                        
                         
                            }, 
                          ),
              ),
               _chatInput(),
             ],
           ),
           
           
      )
      );
  }

  Widget _appbar(){
    return Row(
      children: [
        IconButton(onPressed: (){
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (_)=>Homepage()));
        }, icon: Icon(Icons.arrow_back,color: Colors.white,)),
        ClipOval(
          child: ClipRect(
            child: CachedNetworkImage(
              width: mq.height * .05,
              height: mq.height * .05,
            imageUrl: widget.user.image,
            // placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => CircleAvatar(child: Icon(Icons.person),)
                 ),
          ),
        ),
        SizedBox(width: 8,),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.user.name,
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15),
            ),
            Text('Last seen ...',style: TextStyle(color: Colors.white,fontSize: 12),)
          ],
        )
      ],
    );
  }

  Widget _chatInput(){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: mq.height *.01,horizontal: mq.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Row(
                 children: [
                  IconButton(onPressed: (){}, icon:Icon(Icons.emoji_emotions,color:Colors.tealAccent.shade700,size: 26,)),
              
                  Expanded(child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Type here..',
                      hintStyle: TextStyle(color: Colors.tealAccent.shade700),
                      border: InputBorder.none
                    ),
                  )
                  ),
                  IconButton(onPressed: (){}, icon:Icon(Icons.image,color:Colors.tealAccent.shade700)),
              
                  IconButton(onPressed: (){}, icon:Icon(Icons.camera_alt_outlined,color:Colors.tealAccent.shade700)),
                 ],
              ),
            ),
          ),
          MaterialButton(onPressed: (){
               if(_textController.text.isNotEmpty){
                APIs.sendMessage(widget.user, _textController.text);
                _textController.text = '';
               }
          },
          minWidth: 0,
          padding:EdgeInsets.only(top: 10,bottom: 10,left: 10,right: 5),
          shape: CircleBorder(),
          color: Colors.tealAccent.shade700,
          child: Icon(Icons.send,color: Colors.white,size: 25,),
      
          ),
      
        ],
      ),
    );
  }
}