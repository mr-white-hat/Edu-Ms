import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hacksrm/class.dart';
import 'package:hacksrm/models/studentinfo.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox<String>("Classes");
  Hive.registerAdapter(StudentinfoAdapter());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<FormState> _form = GlobalKey<FormState>();
  String newclassname;
  @override
  Widget build(BuildContext context) {
    final classlist = Hive.box<String>("Classes");
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // classlist.add("hello");
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Add a Classroom"),
                content: Form(
                  key: _form,
                  child: Container(
                    height: height * .17,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextFormField(
                          onSaved: (newValue) => newclassname = newValue,
                          validator: (value) {
                            if (value.length <= 3) {
                              return 'like this difficult';
                            }
                            return null;
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FlatButton.icon(
                              onPressed: () {
                                if (_form.currentState.validate()) {
                                  _form.currentState.save();
                                  classlist.add(newclassname);
                                  Navigator.pop(context);
                                }
                              },
                              icon: Icon(
                                Icons.done,
                                color: Colors.green,
                              ),
                              label: Text(
                                "Add",
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<String>("Classes").listenable(),
        builder: (context, Box<String> box, widget) {
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(Icons.class__outlined),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassRoom(box.getAt(index)),
                    ),
                  );
                },
                onLongPress: () {
                  classlist.deleteAt(index);
                },
                title: Text(box.getAt(index)),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    Hive.box("Classes").close();
    super.dispose();
  }
}
