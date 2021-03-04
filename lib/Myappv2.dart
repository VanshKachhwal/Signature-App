import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'DrawingScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyListItem{
  String title = "";
  // String subtitle = "";
  MyListItem(String title){
    this.title = title;
    // this.subtitle = subtitle;
  }
  MyListItem.fromMap(Map map):
        this.title = map['title'];

  Map toMap(){
    return{
      'title': this.title
    };
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, title: "Design 1", home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  TextEditingController t2 = TextEditingController();

  dialogBox(BuildContext context) {

    return showDialog(context: context, builder: (context)
    {
      return AlertDialog(
        contentPadding: EdgeInsets.all(10.0),
        content: TextField(
          controller: t2,
          decoration: InputDecoration(
            hintText: "Add Title",
            labelStyle: TextStyle(
                color: Colors.black
            ),
            border: OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          MaterialButton(
              padding: EdgeInsets.all(10.0),
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black)
              ),
              child: Text("Cancel"),
              color: Colors.red[100],
              onPressed: () {
                // addNewItemToList(t2.text, "subtitle");

                t2.clear();
                Navigator.of(context).pop();
              }),
          MaterialButton(
              padding: EdgeInsets.all(10.0),
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black)
              ),
              child: Text("Add"),
              color: Colors.green[100],
              onPressed: () {
                addNewItemToList(t2.text);
                t2.clear();
                Navigator.of(context).pop();
              }),
        ],
      );
    });
  }

  List<MyListItem> listItems = [];
  List<MyListItem> listItemsC = [];
  SharedPreferences sharedPreferences;

  @override
  void initState(){
    initSharedPreferences();
    super.initState();
  }

  initSharedPreferences() async{
    sharedPreferences = await SharedPreferences.getInstance();
    loadData();
  }

  String val = "";

  void addNewItemToList(String title){
    setState(() {
      listItems.add(MyListItem(title));
      listItemsC = listItems;
      saveData();
    });

  }

  TextEditingController t1 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: new ListView.builder(
          itemCount: listItemsC.length + 1,
          itemBuilder: (context, int index){
            return index == 0? searchBar() : new Dismissible(
                key: new Key(listItemsC[index-1].title),
                onDismissed: (direction){
                  setState(() {
                    listItemsC.removeAt(index-1);
                    listItems = listItemsC;
                    saveData();
                  });

                  Scaffold.of(context).showSnackBar(new SnackBar(
                    content: new Text("Item Deleted"),
                    duration: Duration(seconds:1),
                  ));
                },
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: new Card(
                    child: ListTile(
                      leading: Icon(Icons.landscape),
                      trailing: Icon(Icons.arrow_right),
                      title: Text(listItemsC[index-1].title,
                        style: TextStyle(
                            fontWeight: FontWeight.w500
                        ),),
                      onTap: () {
                        String titleBar = listItemsC[index-1].title;
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => DrawingScreen(value: titleBar)));
                      },
                    ),
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey, width: 0.5)
                    ),
                  ),
                ));
          }),
      floatingActionButton: new FloatingActionButton(
          tooltip: "Add",
          backgroundColor: Color.alphaBlend(Colors.deepPurpleAccent, Colors.white),
          child: new Icon(Icons.add),
          onPressed: (){
            dialogBox(context);

          }),
    );


  }

  searchBar(){
    return Padding(
        padding: const EdgeInsets.all(3.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search...'
        ),
        onChanged: (text){
          text = text.toLowerCase();
          setState(() {
            listItemsC = listItems.where((element) {
              var elementTitle = element.title.toLowerCase();
              return elementTitle.contains(text);
            }).toList();
          });
        },
      ),
    );
  }

  getAppBar() {
    return PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: Container(
          height: 100,
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 20.0),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: <Color>[Colors.purple, Colors.deepPurpleAccent])),
          child: Text(
            "Pixtar",
            style: TextStyle(
                color: Colors.white60,
                fontSize: 30.0,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w600),
          ),
        ));
  }

  void saveData(){
    List<String> spList = listItemsC.map((item) => json.encode(item.toMap())).toList();
    sharedPreferences.setStringList('listItems', spList);
  }

  void loadData(){
    List<String> spList = sharedPreferences.getStringList('listItems');
    listItemsC = spList.map((item) => MyListItem.fromMap(json.decode(item))).toList();
    setState(() {

    });
  }
}