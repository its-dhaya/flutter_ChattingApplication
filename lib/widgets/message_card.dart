import 'dart:developer';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattify/api/apis.dart';
import 'package:chattify/helper/date_util.dart';
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
  
     if(widget.message.read.isEmpty){
      APIs.updateMessageStatus(widget.message);
      
     }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
         Flexible(
           child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image ? mq.width * .03:mq.width *.04),
            margin: EdgeInsets.symmetric(horizontal: mq.width * .02,vertical: mq.height *.01),
            decoration: BoxDecoration(color: Color.fromARGB(255, 57, 154, 196,
            
            ),
            borderRadius: BorderRadius.circular(25)
            ),
                   
            child: widget.message.type == Type.text ?
                Text(widget.message.msg,
            style: TextStyle(fontSize: 15,color: Colors.white),
                ):ClipRRect(
                  borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
            imageUrl: widget.message.msg,
          
            placeholder: (context, url) => CircularProgressIndicator(strokeWidth: 2,),
            errorWidget: (context, url, error) => Icon(Icons.image,size:70),)
                 ),
          ),
           ),
        
        
         Padding(
           padding:  EdgeInsets.only(right: mq.width * .04),
           child: Text(DateUtil.getformatted(context: context, time: widget.message.sent),
           style: TextStyle(color: Colors.black54),),
         ),
         

    ]
    );
    
  }

  Widget _tealMessage(){
 
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
 
         Row(
           children: [
            SizedBox(width:  mq.width * .04,),
          if(widget.message.read.isNotEmpty)
            Icon(Icons.done_all_rounded,color: Colors.blue,size:  20,),
            SizedBox(width: 2,),
              Text(
                DateUtil.getformatted(context: context, time: widget.message.sent),
              ),
           ],
         ),
            Flexible(
           child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image ? mq.width * .03:mq.width *.04),
            margin: EdgeInsets.symmetric(horizontal: mq.width * .02,vertical: mq.height *.01),
            decoration: BoxDecoration(color: Colors.tealAccent.shade700,
            borderRadius: BorderRadius.circular(25)
            ),
                   
            child:  widget.message.type == Type.text ?
                Text(widget.message.msg,
            style: TextStyle(fontSize: 15,color: Colors.white),
                ):ClipRRect(
                  borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
            imageUrl: widget.message.msg,
          
            placeholder: (context, url) => CircularProgressIndicator(strokeWidth: 2,),
            errorWidget: (context, url, error) => Icon(Icons.image,size:70),)
                 ),
            ),
           ),
         

    ],);
  }
}