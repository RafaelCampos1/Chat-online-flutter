import 'dart:io';

import 'package:chat/ChatMessage.dart';
import 'package:chat/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({Key key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey <ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GoogleSignIn googleSignIn = GoogleSignIn();

  FirebaseUser _currentUser;
  bool _isloading = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<FirebaseUser> _getUser() async{
    if(_currentUser !=null)
      return _currentUser;

    try{
      // fazendo login no google/firebase
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
      final AuthResult authResult = await FirebaseAuth.instance.signInWithCredential(credential);

      final FirebaseUser user = authResult.user;

      return user;
    }catch(error){
    return null;
    }
  }

  //         {} usado pois é opcional da funcao (receberá uma foto ou uma msg)
 void _sendMessage({String text, File img}) async{
    final FirebaseUser user = await _getUser();

    if(user ==null){
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Não foi possivel fazer o login. tente novamente!"),
        )
      );
    }

   //dynamic é o tipo de map q o firebase recebe
   Map<String, dynamic> data = {
      "uid": user.uid,
     "senderName": user.displayName,
     "senderPhotoUrl": user.photoUrl,
     "time": Timestamp.now(),
     "hour" : DateFormat.jm().format(DateTime.now()),
   };

   /* String datatime = data["time"].toString();
    DateTime now = DateTime.parse(datatime);
    String time = DateFormat.jm().format(now);



    print(time);*/

   if(text!=null)
     //crio o campo text
     data['emissor'] = text;
   //                                         envio data para adicionar o fBase


  if(img != null){
    // quando envio um arquivo irá para o storage do firebase
    //                                                    child é a pasta
    StorageUploadTask task = FirebaseStorage.instance.ref().child(
      //nome pelo millisegundo q enviei
     user.uid + DateTime.now().millisecondsSinceEpoch.toString()
    ).putFile(img);

    // carregando imagem com setState
    setState(() {
      _isloading = true;
    });

    //espera a funcao upload (task) terminar
  StorageTaskSnapshot taskSnapshot = await task.onComplete;
  String url = await taskSnapshot.ref.getDownloadURL();
  data['imgUrl'] = url;
  }

    // finalizou imagem com setState
    setState(() {
      _isloading = false;
    });

  if(text != null)
    data['text'] = text;

    Firestore.instance.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _currentUser != null ? 'Olá, ${_currentUser.displayName}' : 'chat app',
        ),
        elevation: 0,
        actions: [
          // if usuario nao for nulo aparece o botao de exit_app
          _currentUser !=null ? IconButton(
              icon:Icon(Icons.exit_to_app),
              onPressed: (){
                FirebaseAuth.instance.signOut();
                googleSignIn.signOut();
                //snackbar para aparecer que deslogou
                _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      content: Text("Voce deslogou com sucesso!"),
                    )
                  );
                },
              // se nao estiver logado aparece apenas um container
          ) : Container(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection("messages").orderBy("time").snapshots(),
                builder: (context, snapshot){
                  switch(snapshot.connectionState){
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                     List<DocumentSnapshot> document = snapshot.data.documents.reversed.toList();
                     return ListView.builder(
                       itemCount: document.length,
                       reverse: true,
                       itemBuilder:(context, index){
                         //                                       funcao true ou false
                         //                                       interrogacao para tirar o nulo ja que pode comecar null
                         return ChatMessage(document[index].data, document[index].data["uid"] == _currentUser?.uid);
                       }
                     );
                  }
                }
              ),
          ),
          //se estiver carregando aparece um progress senao um container
          _isloading ? LinearProgressIndicator() : Container(),
          TextComposer(_sendMessage),
        ]
      ),
    );
  }
}
