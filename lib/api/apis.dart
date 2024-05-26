import 'dart:developer';
import 'dart:io';


import 'package:chattify/widgets/chat_user_data.dart';
import 'package:chattify/widgets/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

class APIs{
  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;
  
  static late ChatUserData me;

  static get user => auth.currentUser!;


  static FirebaseMessaging firebasemessage = FirebaseMessaging.instance;

  static Future<void> getFirebaseMessagToken()async {
   await firebasemessage.requestPermission();

   await firebasemessage.getToken().then((t){
    if(t!=null){
      me.pushToken = t;
      log('Pushtoken: $t');
    }
   });

  }


  static Future<bool> userExists()async{
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }
  static Future<void> getselfInfo()async{
    return await firestore
    .collection('users')
    .doc(user.uid)
    .get()
    .then((user) async{
      if(user.exists){
        me =ChatUserData.fromJson(user.data()!);
       await  getFirebaseMessagToken();
         APIs.updateActiveStatus(true);
         log('My data:${user.data()}');

      }else{
        await createUser().then((value)=>getselfInfo());
      }
    });
  }

  static Future<void> createUser()async{
    final time =DateTime.now().millisecondsSinceEpoch.toString();

    final chatuser = ChatUserData(
    id: user.uid,
    name: user.displayName.toString(),
    email: user.email.toString(),
    about: "Hey, I'm using chattify!",
    image: user.photoURL.toString(),
    createdAt: time,
    isOnline:false ,
    lastActive: time,
    pushToken: '',
    );

    return await firestore.collection('users').doc(user.uid).set(chatuser.toJson());
  }

  static Stream<QuerySnapshot<Map<String,dynamic>>> getAllusers(){
    return APIs.firestore.collection('users').where('id',isNotEqualTo: user.uid).snapshots();
  }

   static Future<void> updateUserInfo()async{
    return await firestore.collection('users').doc(user.uid).update({
      'name':me.name,
      'about':me.about,
    });
  }

  static Future<void> updateProfilePicture(File file)async{
    final ex = file.path.split('.').last;
    log("Extension:$ex");
    final ref = storage.ref().child('Profile_picture/${user.uid}.$ex');
    await ref.putFile(file,SettableMetadata(contentType: 'image/$ex')).then((p0){
      log('Data transferred:${p0.bytesTransferred / 1000}kb');
    });
   me.image = await ref.getDownloadURL();
   await firestore.collection('users').doc(user.uid).update({
    'image':me.image
   });
  }

static String getConversationID(String id) => user.uid.hashCode <= id.hashCode ?'${user.uid}_$id' : '${id}_${user.uid}';

   static Stream<QuerySnapshot<Map<String,dynamic>>> getAllMessages(ChatUserData user){
    return firestore.collection('chats/${getConversationID(user.id)}/messages/')
    .orderBy('sent',descending: true)
    .snapshots();
  }

  static Future<void> sendMessage(ChatUserData chatuser, String msg,Type type) async{
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final Messages message = Messages(
    msg: msg,
    read: '', 
    told: chatuser.id,
    type: type,
    fromid: user.uid, 
    sent: time);

    final ref  = firestore.collection('chats/${getConversationID(chatuser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }
  static Future<void> updateMessageStatus(Messages message)async {
    firestore.collection('chats/${getConversationID(message.fromid)}/messages/')
    .doc(message.sent)
    .update({'read':DateTime.now().millisecondsSinceEpoch.toString()});
  }
     static Stream<QuerySnapshot<Map<String,dynamic>>> getLastMessages(ChatUserData user){
    return firestore.collection('chats/${getConversationID(user.id)}/messages/')
    .orderBy('sent',descending: true)
    .limit(1)
    .snapshots();
  }

  static Future<void> sendChatImage(ChatUserData chatuser, File file) async{
    final ex = file.path.split('.').last;
    final ref = storage.ref().child('images/${getConversationID(chatuser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ex');
    await ref.putFile(file,SettableMetadata(contentType: 'image/$ex')).then((p0){
      log('Data transferred:${p0.bytesTransferred / 1000}kb');
    });
   final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatuser, imageUrl, Type.image);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(ChatUserData chatuser){
    return firestore
    .collection('users')
    .where('id',isEqualTo: chatuser.id)
    .snapshots();

  }

  static Future<void> updateActiveStatus(bool isOnline)async{
    firestore
    .collection('users')
    .doc(user.uid)
    .update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token':me.pushToken,
    });
  }

}

