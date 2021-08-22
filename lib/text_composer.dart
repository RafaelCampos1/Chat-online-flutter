import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class TextComposer extends StatefulWidget {
  TextComposer(this.sendMessage);
  //         {} usado pois é opcional da funcao (receberá uma foto ou uma msg)
  final Function({String text, File img}) sendMessage;


  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final TextEditingController _controller = TextEditingController();
  bool haveText = false;

  cleanButton(){
    setState(() {
      haveText = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // uso async pois o onPressed tera que esperar eu tirar a foto
          IconButton(onPressed: ()  async{
            final File img = await ImagePicker.pickImage(source: ImageSource.camera);
           //se eu cancelar e a img for nula cancela a operacao com return
            if(img ==null)
              return;
            // tem q especificar que vou enviar so uma imagem
            // pois posso enviar duas coisas diferentes e nesse caso é so uma imagem

            widget.sendMessage(img: img);

          }, icon: Icon(Icons.camera_enhance)),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration.collapsed(hintText: "enviar mensagem"),
              onChanged: (text){
                setState(() {
                  haveText = text.isNotEmpty;
                });
              },
              onSubmitted: (text){
                // tem q especificar que vou enviar so um texto
                // pois posso enviar duas coisas diferentes e nesse caso é so um texto
                widget.sendMessage(text: text);
                _controller.clear();
                cleanButton();
              },),

          ),
          IconButton(
            icon: Icon(Icons.send),
            // ou seja, qnd pressionar o botao se o "isComposing" nao for nulo faça algo senao é nullo
           // se tiver texto, pode clicar, caso nao fique em null (nao pode clicar)
            onPressed: haveText? ( ) {
              //especifito aqui tbm
              widget.sendMessage(text: _controller.text);
              _controller.clear();
              cleanButton();} : null,
          ),
        ],
      ),
    );
  }
}
