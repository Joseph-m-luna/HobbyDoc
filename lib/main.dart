import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path/path.dart' as p;

void main() {
  runApp(const MyApp());
}

class Palette {
  static const MaterialColor cinnamon = const MaterialColor(
    0xff52322e, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    const <int, Color>{
      50: const Color(0xff313131),//10%
      100: const Color(0xff575757),//20%
      200: const Color(0xff707070),//30%
      300: const Color(0xff73605a),//40%
      400: const Color(0xff343434),//50%
      500: const Color(0xff838383),//60%
      600: const Color(0xff494848),//70%
      700: const Color(0xff52322e),//80%
      800: const Color(0xff000000),//90%
      900: const Color(0xff000000),//100%
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);



  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naviation Demo',
      theme: ThemeData(
        primarySwatch: Palette.cinnamon,
      ),
      home: const LandingPage(title: 'Landing Page'),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Palette.cinnamon.shade300,
        ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(80.0),
            alignment: Alignment.center,
            child: const Image(
              image: AssetImage('assets/images/HobbyDocLogo.png'),
              width: 180.0,
              height: 180.0,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              'Thank you for downloading HobbyDoc!\n\nLets take a look around, start some projects and get going!',
              style: TextStyle(
                fontSize: 30.0,
                fontFamily: 'Times New Roman',
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 80),
            child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const InfoView(title: 'My Projects');
              }));
            },
            style: ElevatedButton.styleFrom(
              primary: Palette.cinnamon.shade50,
              onPrimary: Palette.cinnamon.shade900,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                textStyle: TextStyle(
                fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            ),
            child: Text('Start Projects')
        ),
        ),// Add more children here
        ]
      ),
      ),
    );
  }
}

class InfoView extends StatelessWidget {
  const InfoView({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Container(
            decoration: BoxDecoration(
            color: Palette.cinnamon.shade300,
            ),
        child: Center (
          child: FutureBuilder(
            future: getProjHeaders(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List? nullable = snapshot.data;
                if (nullable != null) {
                  var items = nullable;
                  var projList = ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: items.length + 1,
                    itemBuilder: (context, index) {
                      if (index == items.length) {
                        return ListTile(
                          title: Text('+ New Project'),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return ProjectEdit(title: 'New Project', isNew: true);
                            }));
                          }
                        );
                      } else {
                        return ListTile(
                          title: Text(items[index]),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return Edit(title: items[index]);
                            }));
                          }
                        );
                      }
                    }
                  );
                  return projList;
                } else {
                  return Text('nullableProtectionFailed');
                }
              } else if (snapshot.hasError) {
                return Text('error: ${snapshot.error}');
              } else {
                return CircularProgressIndicator();
              }
            }
        ),
    ),
    )
    );
  }

  Future<List> getProjHeaders() async {
    var docs = await getApplicationDocumentsDirectory();
    var projFile = File(docs.path + '/' + 'projects.txt');
    print(projFile.path);
    if (!await projFile.exists()) {
      await projFile.create();
      print('created file');
    }
    var projPaths = projFile.readAsString();
    String projCont = await projPaths;
    var paths = projCont.split('\n');

    List titleStrings = [];

    for (String path in paths) {
      if (path != '') {
        var datafile = File(path);
        var futureData = datafile.readAsString();
        String data = await futureData;
        titleStrings.add(data.split('\n')[0]);
      }
    }
    print(titleStrings);
    return titleStrings;
  }
}

class ProjectEdit extends StatelessWidget {
  ProjectEdit({Key? key, required this.title, required this.isNew}) : super(key: key);
  final String title;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    var name = '';
    var summary = '';
    var resources = '';
    var imagePath = 'None';
    var isNewChangable = isNew;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        decoration: BoxDecoration(
        color: Palette.cinnamon.shade300,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter unique name here',
            ),
            onChanged: (text) {
              // Do something with the entered name
              name = text;
            },
            maxLines: null,
            maxLength: 50,
          ),
          SizedBox(height: 20), // Add some spacing between the text fields
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter Project Summary Here',
            ),
            maxLines: null,
            maxLength: 2000,
            onChanged: (text) {
              summary = text;
            },
          ),
          SizedBox(height: 20), // Add some spacing between the text fields
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter sources here',
            ),
            maxLines: null,
            maxLength: 2000,
            onChanged: (text) {
              resources = text;
            },
          ),
          ElevatedButton(
            child: Text(
                'Select Image',
                style: TextStyle(fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              primary: Palette.cinnamon.shade50,
              onPrimary: Palette.cinnamon.shade100,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              textStyle: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onPressed: () async {
              File selectedImage = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ImagePickerScreen();
              }));
              print('SELECTING IMAGE: ' + selectedImage.path);
              var docPath = await getApplicationDocumentsDirectory();
              if (selectedImage == null) {
                print('null selection');
                imagePath = 'None';
              } else {
                imagePath = docPath.path + '/' + name + p.extension(selectedImage.path);
                final File newImage = await selectedImage.copy(imagePath);
              }
            }
          ),
          ElevatedButton(
              child: Text(
                  "Finish Editing",
                  style: TextStyle(fontSize: 14)
              ),
              style: ElevatedButton.styleFrom(
                primary: Palette.cinnamon.shade50,
                onPrimary: Palette.cinnamon.shade100,
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                textStyle: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () {
                if (isNewChangable == true) {
                  isNewChangable = false;
                  //ADD PROTECTION HERE AGAINST DUPLICATE NAMES
                  String filename = '$name.txt';
                  String content = '$name\n$summary\n$resources\n$imagePath';
                  createFile(filename, content);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const InfoView(title: 'My Projects');
                  }));
                }
              }
          ),
        ],
      ),
    )
    );
  }
}

class ImagePickerScreen extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    setState(() {
      _imageFile = File(pickedFile!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker'),
      ),
      body: Container(
        decoration: BoxDecoration(
        color: Palette.cinnamon.shade300,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imageFile == null
                ? Text('No image selected.')
                : Image.file(_imageFile!),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              child: Text('Pick Image from Gallery'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _imageFile);
              },
              child: Text('Select Current Photo'),
            ),
          ],
        ),
      ),
    )
    );
  }
}

void createFile(String fName, String fContent) async {
  var docPath = await getApplicationDocumentsDirectory();
  String fullPath = docPath.path + '/' + fName;


  var newFile = File(fullPath);
  newFile.writeAsStringSync(fContent);
  File projFile = File(docPath.path + '/' + 'projects.txt');
  print(docPath.path + '/' + 'projects.txt');
  projFile.writeAsString(fullPath + '\n', mode: FileMode.append);
}

//must be separate, as this requires a Future Builder
class Edit extends StatelessWidget {
  const Edit({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    String name = title;
    String body = '';
    String resource = '';
    String imagePath = '';
    return Scaffold(
      appBar: AppBar(
        title: Text('View and Edit Project'),
      ),
      body: Container(
          decoration: BoxDecoration(
          color: Palette.cinnamon.shade300,
        ),
      child: Center(
        child: FutureBuilder(
            future: getProjectContent(title),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List? nullable = snapshot.data;
                if (nullable != null) {
                  var items = nullable;
                  var projList = ListView.separated(
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        if (index == 0) {//title

                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              child: Text(
                            items[index],
                            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold), textAlign: TextAlign.center,
                          )
                          );
                        } else if (index == 1){//body
                          TextEditingController bodyCtl = TextEditingController(text: items[index]);
                          return TextField(
                            controller: bodyCtl,
                            decoration: InputDecoration(
                              hintText: 'Enter Project Outline Here',
                            ),
                            onChanged: (text) {
                              // Do something with the entered name
                              body = text;
                            },
                            maxLines: null,
                            maxLength: 2000,
                          );
                        } else if (index == 2) {//resource
                          TextEditingController sourceCtl = TextEditingController(text: items[index]);
                          return TextField(
                            controller: sourceCtl,
                            decoration: InputDecoration(
                              hintText: "Enter your resources here",
                            ),
                            onChanged: (text) {
                              // Do something with the entered name
                              resource = text;
                            },
                            maxLines: null,
                            maxLength: 2000,
                          );

                        } else if (index == 3) {//image
                          imagePath = items[index];
                          print(imagePath);
                          File checkFile = File(imagePath);
                          if (!checkFile.existsSync()) {
                            return Text('No Image Selected');
                          } else {
                            return Image.file(
                              checkFile,
                              fit: BoxFit.cover,
                            );;
                          }
                        } else if (index == 4) {
                          return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 120, vertical: 20),
                              child: ElevatedButton(

                              onPressed: () async {
                                var docs = await getApplicationDocumentsDirectory();
                                var projFile = File(docs.path + '/' + '$title.txt');
                                projFile.writeAsString('$name\n$body\n$resource\n$imagePath');
                                //Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  //return const InfoView(title: 'My Projects');
                                Navigator.pop(context);
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return const InfoView(title: 'My Projects');
                                }));
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Palette.cinnamon.shade50,
                                onPrimary: Palette.cinnamon.shade100,
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                textStyle: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Text('Save Project'),
                          ),
                        );
                        }
                      }
                  );
                  return projList;
                } else {
                  return Text('nullableProtectionFailed');
                }
              } else if (snapshot.hasError) {
                return Text('error: ${snapshot.error}');
              } else {
                return CircularProgressIndicator();
              }
            }
        ),
      ),
    )
    );
  }

  Future<List> getProjectContent(String title) async {
    var docs = await getApplicationDocumentsDirectory();
    var projFile = File(docs.path + '/' + '$title.txt');
    print(projFile.path);
    var projPaths = projFile.readAsString();
    String projCont = await projPaths;
    var data = projCont.split('\n');

    List titleStrings = [];
    for (String item in data) {
      titleStrings.add(item);
    }
    print(titleStrings);
    titleStrings.add('button');
    print(titleStrings);
    return titleStrings;
  }
}

//TODO: Fix it so that newlines don't break things in text boxes
//Make more editing options
