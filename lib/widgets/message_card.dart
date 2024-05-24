import 'dart:ui';

import 'package:chattify/api/apis.dart';
import 'package:chattify/main.dart';
import 'package:chattify/widgets/message.dart';
import 'package:flutter/material.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key,required this.message});

  final Messages message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.fromid ? _tealMessage() :_blueMessage();
  }

  Widget _blueMessage(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
         Flexible(
           child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(horizontal: mq.width * .02,vertical: mq.height *.01),
            decoration: BoxDecoration(color: Color.fromARGB(255, 57, 154, 196,
            
            ),
            borderRadius: BorderRadius.circular(25)
            ),
                   
            child: Text(widget.message.msg,
            style: TextStyle(fontSize: 15,color: Colors.white),
            ),
           ),
         ),
         Padding(
           padding:  EdgeInsets.only(right: mq.width * .04),
           child: Text(widget.message.sent,
           style: TextStyle(color: Colors.black54),),
         )

    ],);
  }

  Widget _tealMessage(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
 
         Row(
           children: [
            SizedBox(width:  mq.width * .04,),
            Icon(Icons.done_all_rounded,color: Colors.blue,size:  20,),
            SizedBox(width: 2,),
              Text(widget.message.read + '12:00 AM')
           ],
         ),
            Flexible(
           child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(horizontal: mq.width * .02,vertical: mq.height *.01),
            decoration: BoxDecoration(color: Colors.tealAccent.shade700,
            borderRadius: BorderRadius.circular(25)
            ),
                   
            child: Text(widget.message.msg,
            style: TextStyle(fontSize: 15,color: Colors.white),
            ),
           ),
         ),

    ],);;
  }
}