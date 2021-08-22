import 'dart:async';

import 'package:chat/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';


void main() async {






  runApp(MyApp());
  /*Firestore.instance.collection("mensagens").document("msg1").updateData({
    "texto" : "olá",
    "from" : "rafael",
    "read" : true
  });*/
  QuerySnapshot snapshot = await Firestore.instance.collection("mensagens").getDocuments();
  snapshot.documents.forEach((element) {
    print(element.data);
  });
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      title: 'Chat Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        primarySwatch: Colors.cyan,
        iconTheme: IconThemeData(
          color: Colors.blue
        ),
      ),
      home: ChatScreen(),
    );
  }
}