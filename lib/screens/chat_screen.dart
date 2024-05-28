import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattify/api/apis.dart';
import 'package:chattify/helper/date_util.dart';
import 'package:chattify/main.dart';
import 'package:chattify/screens/homepage.dart';
import 'package:chattify/screens/view_profilescreen%20.dart';
import 'package:chattify/widgets/chat_user_data.dart';
import 'package:chattify/widgets/message.dart';
import 'package:chattify/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {

  final ChatUserData user;
  const ChatScreen({super.key,required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
 List<Messages> _list = [];

bool _showemoji= false, _isUploading = false;

 final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.tealAccent.shade700));
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: 
        // ignore: deprecated_member_use
        WillPopScope(
          onWillPop: (){
            if(_showemoji){
              setState(() =>
                _showemoji = ! _showemoji
              );
              return Future.value(false);
            }else{
              return Future.value(true);
            }
          },
          child: Scaffold(
               appBar: AppBar(
                backgroundColor: Colors.tealAccent.shade700,
                automaticallyImplyLeading: true,
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
                      reverse: true,
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

                  if(_isUploading)
                    Align(
                      alignment: Alignment.centerRight,
                      
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                        child: CircularProgressIndicator(strokeWidth: 2,),
                      )),

                   _chatInput(),
                  if(_showemoji)
                   SizedBox(
                    height:  mq.height * .35,
                     child: EmojiPicker(
                     
                     
                         textEditingController: _textController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                         config: Config(
                           emojiViewConfig: EmojiViewConfig(
                             columns: 8,
                             emojiSizeMax: 28 * (Platform.isIOS ? 1.20 :1.0)
                           )
                         ),
                     ),
                   )
                 ],
               ),
               
               
          ),
        )
        ),
    );
  }

  Widget _appbar(){
    return  InkWell(
      onTap: (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>ViewProfilescreen(user: widget.user)));
      },
      child: StreamBuilder(stream:APIs.getUserInfo(widget.user) ,builder: (context,snapshot){
          final data = snapshot.data?.docs;
           final list = data?.map((e) => ChatUserData.fromJson(e.data())).toList() ?? [];
         
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
            imageUrl:list.isNotEmpty? list[0].image: widget.user.image,
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
            Text(list.isNotEmpty? list[0].name: widget.user.name,
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15),
            ),
            Text(
              list.isNotEmpty
              ?list[0].isOnline?'online'
              :DateUtil.getLastActiveTime(context: context, 
              lastActive: list[0].lastActive)
              :DateUtil.getLastActiveTime(context: context,
               lastActive: widget.user.lastActive)
              ,style: TextStyle(color: Colors.white,fontSize: 12),)
          ],
        )
      ],
    );
      },),
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
                  IconButton(onPressed: (){
                    setState(() {
                      _showemoji = !_showemoji;
                    });
                  }, icon:Icon(Icons.emoji_emotions,color:Colors.tealAccent.shade700,size: 26,)),
              
                  Expanded(child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: (){
                      if(_showemoji) setState(() {
                        _showemoji = !_showemoji;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Type here..',
                      hintStyle: TextStyle(color: Colors.tealAccent.shade700),
                      border: InputBorder.none
                    ),
                  )
                  ),
                  IconButton(onPressed: () async {
                   final ImagePicker picker = ImagePicker();
                  final List<XFile> images = await picker.pickMultiImage(imageQuality: 70);
                  for (var i in images){
                    log('Image path:${i.path}');
                                        setState(() =>
                    _isUploading = true
                    
                    );
                    await APIs.sendChatImage(widget.user, File(i.path));
                                        setState(() =>
                    _isUploading = false
                    
                    );
                  }

                 
                  }, icon:Icon(Icons.image,color:Colors.tealAccent.shade700)),
              
                  IconButton(onPressed: () async {
                     final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.camera,imageQuality: 70);
                  if(image!=null){
                    log('Image path: ${image.path}');
                    setState(() =>
                    _isUploading = true
                    
                    );
                    await  APIs.sendChatImage(widget.user,File(image.path));
                     setState(() =>
                    _isUploading = false
                    
                    );
                  }
                 
                  }, icon:Icon(Icons.camera_alt_outlined,color:Colors.tealAccent.shade700)),
                 ],
              ),
            ),
          ),
          MaterialButton(onPressed: (){
               if(_textController.text.isNotEmpty){
                if(_list.isEmpty){
                    APIs.sendfirstmessage(widget.user, _textController.text, Type.text);
                }else{
                  APIs.sendMessage(widget.user, _textController.text, Type.text);
                }
                
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