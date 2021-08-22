import 'dart:ui';

import 'package:flutter/material.dart';


class ChatMessage extends StatelessWidget {
  ChatMessage(this.data, this.mine);
  final Map<String, dynamic> data;

  bool mine;

  @override
  Widget build(BuildContext context) {
    MediaQueryData deviceInfo = MediaQuery.of(context);

    return Container(
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Row(
          children: [
            !mine ?// se nao for meu faz isso
            Padding(padding: const EdgeInsets.only(right:16),
              child: CircleAvatar(
                backgroundImage: NetworkImage(data["senderPhotoUrl"]),
              ),
            ) : Container(),


            Expanded(
              child: Column(
                //              se for meu o alinhamento e no final senao e no comeco
                crossAxisAlignment: mine? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [



                  new Container(

                      decoration: new BoxDecoration(

                          color: Colors.grey,
                          borderRadius: new BorderRadius.vertical(
                            top: const Radius.circular(10),
                            bottom: const Radius.circular(10),
                          )
                      ),


                      margin: EdgeInsets.all(1.0),
                      padding: EdgeInsets.only(left: 10.0, right: 10, bottom: 6, top: 10),

                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [





                          Text(data["senderName"],
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15
                              )),

                          Container(



                            child: Wrap(
                              alignment: WrapAlignment.end,
                              children: [


                                data["imgUrl"] != null ?
                                Image.network(data["imgUrl"], width: 50,)

                                    :
                                Text(
                                  data["emissor"],

                                  //              se for meu o alinhamento e no final senao e no comeco


                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15
                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(right: 15)),
                                Text(
                                  data["hour"],
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 15
                                  ),
                                ),




                              ],

                            ),



                          ),






                        ],
                      )




                  ),




                ],
              ),
            ),
            mine ? // se for meu faz isso
            Padding(padding: const EdgeInsets.only(right:16),
              child: CircleAvatar(
                backgroundImage: NetworkImage(data["senderPhotoUrl"]),
              ),
            ) : Container(),
          ],
        )
    );

  }

}
