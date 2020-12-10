import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Survey',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SurveyList(),
    );
  }
}

class SurveyList extends StatefulWidget {
  @override
  _SurveyListState createState() => _SurveyListState();
}

class _SurveyListState extends State<SurveyList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Simple Survey"),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection("dilanketi").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: LinearProgressIndicator());
            } else {
             return buildBody(context, snapshot.data.docs);
            }
          },
        )
        //
        );
  }

  buildBody(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: EdgeInsets.only(top: 20),
      children:
          snapshot.map<Widget>((data) => buildListItem(context, data)).toList(),
    );
  }

  buildListItem(BuildContext context, DocumentSnapshot data) {
    final row = Survey.fromSnapshot(data);
    return Padding(
      key: ValueKey(row.isim),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0)),
        child: ListTile(
          title: Text(row.isim),
          trailing: Text(row.oy.toString()),
          onTap: () {
            FirebaseFirestore.instance.runTransaction((transaction) async{
              final freshSnapshot = await transaction.get(row.reference);//Snapshot
              final fresh = Survey.fromSnapshot(freshSnapshot);//Survey
              
              await transaction.update(row.reference, {"oy":fresh.oy+1});

            });
          },
        ),
      ),
    );
  }
}

final fakeSnapshot = [
  {"isim": "C#", "oy": 3},
  {"isim": "Java", "oy": 6},
  {"isim": "C++", "oy": 12},
  {"isim": "Pyhthon", "oy": 44}
];

class Survey {
  String isim;
  int oy;

  DocumentReference reference;

  Survey.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map["isim"] != null),
        assert(map["oy"] != null),
        isim = map["isim"],
        oy = map["oy"];

  Survey.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);
}
