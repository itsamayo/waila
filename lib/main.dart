import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'WAILA',
      home: new MyHomePage(title: 'What Am I Looking At  🕵'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<File> _imageFile;
  var tags;
  var hashtags;
  var scores;
  var loaded = false;

  Choice _selectedChoice = choices[0]; // The app's "state".

  void _select(Choice choice) {
    // Causes the app to rebuild with the new _selectedChoice.
    setState(() {
      _selectedChoice = choice;
      var alert = new AlertDialog(
        title: new Text("About"),
        content: new Text("Waila 1.0.3\n\nAn open source tool developed to classify and generate hashtags from an image using machine learning\n\nTo view code base visit https://github.com/AshKetchumza\n\nCreator: Ashley Sanders\nLicense: Apache License 2.0"),
      );
      showDialog(context: context, child: alert);
    });
  }  

  void _onImageButtonPressed(ImageSource source) {    
    setState(() {
      loaded = false;
      tags = null;
      hashtags = null;
      scores = null;
      _imageFile = ImagePicker.pickImage(source: source); 
      // _tempDirectory = getTemporaryDirectory();           
    });    
  }

  void _getHashtags(tag1,tag2,tag3,tag4,tag5) async {    
    loaded = false;
    var dio = new Dio();
    var input = tag1 + " " + tag2 + " " + tag3 + " " + tag4 + " " + tag5;       
    try {
      Response response = await dio.get("https://api.ritekit.com/v1/stats/hashtag-suggestions/"+input+"?client_id=ec4032d280e73adc991430c72c8863dc12e29df6c397");      
      Map<String, dynamic> data = response.data;      
      setState(() {
       hashtags = data;   
       loaded = true;    
      });
      _showHashTags();
      // print(hashtags);
    } catch(e) {
      print(e.reponse.data);
    } 
  }

  void _showHashTags(){    
    setState(() {          
       var alert = new AlertDialog(
         title: new Text("Tap on a tag to copy it.\nOr copy them all at once."),
         content: new ListView.builder(
          itemBuilder: (BuildContext context, int index) =>
              new GestureDetector(
                  child: new Text('#${hashtags['data'][index]['hashtag']} - ${hashtags['data'][index]['exposure']} posts\n'),
                  onTap: () {
                    Clipboard.setData(new ClipboardData(text: '#${hashtags['data'][index]['hashtag']}'));  
                    print('Copied ' + '#${hashtags['data'][index]['hashtag']}');
                    showDialog(context: context, child:
                        new AlertDialog(
                          // title: new Text("Copied #${hashtags['data'][index]['hashtag']}"),                          
                          content: new RichText(
                            text: new TextSpan(
                              // Note: Styles for TextSpans must be explicitly defined.
                              // Child text spans will inherit styles from parent
                              style: new TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                new TextSpan(text: 'Copied '),
                                new TextSpan(text: '#${hashtags['data'][index]['hashtag']} ', style: new TextStyle(fontWeight: FontWeight.bold)),
                                new TextSpan(text: 'to your clipboard'),
                              ],
                            ),
                          ),
                        )
                    );
                  },
                ),              
          itemCount: hashtags['data'].length,
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text('Copy all'),
            onPressed: () {
              var allTags = "";
              for(var i=0;i<hashtags['data'].length;i++){
                allTags = allTags + '#${hashtags['data'][i]['hashtag']} ';
              }
              Clipboard.setData(new ClipboardData(text: allTags));
              print('Copied ' + allTags);
              showDialog(context: context, child:
                  new AlertDialog(                    
                    content: new RichText(
                      text: new TextSpan(
                        // Note: Styles for TextSpans must be explicitly defined.
                        // Child text spans will inherit styles from parent
                        style: new TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          new TextSpan(text: 'Copied '),
                          new TextSpan(text: allTags, style: new TextStyle(fontWeight: FontWeight.bold)),
                          new TextSpan(text: 'to your clipboard'),
                        ],
                      ),
                    ),
                  )
              );
            },
          ),
          new RawMaterialButton(
            child: new Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
       );
       showDialog(context: context, child: alert);      
    });
  }

  void _getTags(path) async {
     var dio = new Dio();
      FormData formData = new FormData.from(<String,dynamic>{        
        // If using in flutter, you can get right file path by path_provider package.
        "file": new UploadFileInfo(new File(path), path)
      });
      try {
        Response response = await dio.post("http://146.185.164.60/api/vision/imageClassify", data: formData);       
        this.setState(() {      
            loaded = true;    
            tags = response.data[0]; 
            scores = response.data[1];         
        });                
        print(tags);   
      }catch(e){
        print(e.response.data);
      } 
  }
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('What Am I Looking At  🕵'),
        backgroundColor: new Color(0xFF00796B),        
        actions: <Widget>[            
            // overflow menu
            new PopupMenuButton<Choice>(
              onSelected: _select,
              itemBuilder: (BuildContext context) {
                return choices.skip(0).map((Choice choice) {
                  return new PopupMenuItem<Choice>(
                    value: choice,
                    child: new Text(choice.title),
                  );
                }).toList();
              },
            ),
          ],
      ),
      body: new Center(
        child: new FutureBuilder<File>(
          future: _imageFile,
          builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.data != null) {  
              if(loaded == false ) {
                _getTags(snapshot.data.path);
              }                
              // return new Image.file(snapshot.data); 
              if(tags==null){               
                return new CircularProgressIndicator();
              } else if (tags.length<5){
                return new Text("That's odd 🤔 We couldn't find anything",
                style: new TextStyle(
                      fontSize: 20.0,
                      fontFamily: 'Roboto',
                      color: new Color(0xFF393939),
                    )
                );                
              } else {
                return new ListView(
                  children: <Widget>[
                    new Card(
                      child: new Column(
                        children: <Widget>[
                          new Image.file(snapshot.data),                          
                        ],
                      ),
                    ),
                    new RaisedButton(
                            child: new Text("Generate #hashtags", 
                              style: new TextStyle(
                                color: Colors.white
                              )),
                            color: new Color(0xFF009688),                            
                            onPressed: (){
                              if(hashtags==null){
                                var loadingMessages = [
                                  "Fetching your #hashtags...hang in there...",
                                  "Sure thing...#hashtags on the way...",
                                  "Your #hashtags will be here any moment now...",
                                ];
                                final random = new Random();
                                var loadedMessage = loadingMessages[random.nextInt(loadingMessages.length)];
                                final firstSnackBar = new SnackBar(content: new Text(loadedMessage));
                                // final secondSnackBar = new SnackBar(content: new Text('Give us just a second...'));                                  
                                Scaffold.of(context).showSnackBar(firstSnackBar);
                                // Scaffold.of(context).showSnackBar(secondSnackBar);
                                _getHashtags(tags[0],tags[1],tags[2],tags[3],tags[4]);
                              } else {
                                _showHashTags();
                              }                                                                                         
                            },
                          ),
                    new ListTile(
                      leading: new Text(scores[0]+"%"),
                      title: new Text(tags[0]),
                    ),
                    new ListTile(
                      leading: new Text(scores[1]+"%"),
                      title: new Text(tags[1]),
                    ),
                    new ListTile(
                      leading: new Text(scores[2]+"%"),
                      title: new Text(tags[2]),
                    ),
                    new ListTile(
                      leading: new Text(scores[3]+"%"),
                      title: new Text(tags[3]),
                    ),
                    new ListTile(
                      leading: new Text(scores[4]+"%"),
                      title: new Text(tags[4]),
                    ),
                  ],
                );
              }              
            } else if (snapshot.error != null) {
              return const Text('error picking image.');
            } else {
              return new Text("Upload an image and, using our super\nfancy AI, we'll try to tell you what \nwe see 🤖",
              style: new TextStyle(
                    fontSize: 20.0,
                    fontFamily: 'Roboto',
                    color: new Color(0xFF393939),
                  )
              );
            }
          },
        ),
      ),
      floatingActionButton: new Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new FloatingActionButton(
            onPressed: () => _onImageButtonPressed(ImageSource.gallery),
            tooltip: 'Pick Image from gallery',
            child: new Icon(Icons.photo_library),
            backgroundColor: new Color(0xFF009688),
          ),
          new Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: new FloatingActionButton(
              onPressed: () => _onImageButtonPressed(ImageSource.camera),
              tooltip: 'Take a Photo',
              child: new Icon(Icons.camera_alt),
              backgroundColor: new Color(0xFF009688),
            ),
          ),
        ],
      ),
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});
  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'About', icon: Icons.directions_car),  
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key key, this.choice}) : super(key: key);
  final Choice choice;
  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.display1;
    return new Card(
      color: Colors.white,
      child: new Center(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Icon(choice.icon, size: 128.0, color: textStyle.color),
            new Text(choice.title, style: textStyle),
          ],
        ),
      ),
    );
  }
}