import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iTunes',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  double baseHeight = 650.0;

  double screenAwareSize(double size, BuildContext context) {
    return size * MediaQuery.of(context).size.height / baseHeight;
  }
  TextEditingController textEditingController = TextEditingController();
  clearTextInput() {
    textEditingController.clear();
  }
  bool _isLoading=false;

  

  List<dynamic> data;
  List<String> songs = List<String>();
  List<String> imgs = List<String>();
  List<String> temp = List<String>();


  String s = "https://itunes.apple.com/search?term=p";
  Future<void> getData(String text) async{
    setState(() {
      _isLoading=true;
    });
    List<String> t = text.split(" ");
    print(t[0]);
    s = "https://itunes.apple.com/search?term=" + t[0];
    if(t.length>1){
      for(var i=1;i<t.length;i++){
        s= s + "+" + t[i];
      }
    }
    final response = await http.get(s);
    var jsonData = json.decode(response.body);
    print(jsonData['results'].length);
    data = jsonData['results'];
    temp.clear();
    for(var i=0;i<data.length;i++){
      if(data[i]['trackName']!=null && data[i]['artworkUrl100']!=null)
        temp.add(data[i]['trackName']);
    }
    imgs.clear();
    for(var i=0;i<data.length;i++){
      if(data[i]['trackName']!=null && data[i]['artworkUrl100']!=null)
        imgs.add(data[i]['artworkUrl100']);
    }
    print(songs);
    setState(() {
      songs=temp;
      print(songs.length);
      _isLoading=false;
      
    if(songs.length==0){
      errorDialog('No songs available for this artist');
      }
    });
  }
  Future<void> errorDialog(String a) async{
    textEditingController.clear();
    songs.clear();
    imgs.clear();
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text(a),
            actions: [
              FlatButton(onPressed: () => Navigator.pop(context), child: Text('Ok'))
            ],
          );
        }
        );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('iTunes'),
      ),
      body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,//Color(0xFF262626),
                          borderRadius: BorderRadius.all(Radius.circular(15.0))),
                      child: TextField(
                        controller: textEditingController,
                        style: new TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search For Any Artist',
                          hintStyle:
                          TextStyle(color: Colors.grey, fontSize: 14.0),
                          labelStyle: TextStyle(color: Colors.white),
                          suffixIcon: IconButton(icon: Icon(Icons.search,color: Colors.black,), onPressed: () {
                            if(textEditingController.text == "")
                              errorDialog('No artist name added for search');
                            else
                              getData(textEditingController.text);
                          })
                        ),
                      ),
                    ),
                  ),
                  _isLoading ? Expanded(child: Center(child: CircularProgressIndicator(backgroundColor: Colors.blueAccent,),)) :
                  Expanded(
                    child:Padding(
                            padding: EdgeInsets.all(5),
                            child: ListView.builder(
                              itemCount: songs.length,
                              itemBuilder: (BuildContext context,int index){
                                return Container(
                                  padding: EdgeInsets.all(7.0),
                                  child: Card(
                                      shape: RoundedRectangleBorder(
                                        
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      color: Colors.grey,
                                      child: Container(
                                        height: 100,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(left: 15),
                                              child: CircleAvatar(
                                                radius: 40,
                                                backgroundImage: NetworkImage(imgs[index]),
                                              ),
                                            ),
                                            Expanded(
                                              child: ListTile(
                                                title: Text(songs[index],style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20
                                                ),),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                );
                              },
                            ),
                          ),
                  )
                ],
              ),
        
      ),
    );
  }
}

