import 'package:flutter/material.dart';
import 'package:sqflite_database/db/db_helper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> notes = [];
  DBHelper? dbRef;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  @override
  void initState() {
    super.initState();
    //this is done to get the instance of DBHelper class because we made it private
    //this instance is a manual variable not some predefind variable
    dbRef = DBHelper.instance;
    getNotes();
  }

  //this method is used for getting the notes from dbhelper class
  void getNotes() async {
    notes = await dbRef!.getAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: notes.isNotEmpty
          ? ListView.builder(
              itemCount: notes.length,
              itemBuilder: (builder, index) {
                return Card(
                  margin: const EdgeInsets.all(5),
                  color: const Color.fromARGB(217, 237, 232, 232),
                  child: ListTile(
                    leading: Text(
                      (index + 1).toString(),
                      textScaleFactor: 1.5,
                    ),
                    title: Text(notes[index][DBHelper.titleColumn]),
                    subtitle: Text(
                      notes[index][DBHelper.descColumn],
                    ),
                    trailing: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () {
                              _titleController.text =
                                  notes[index][DBHelper.titleColumn];
                              _descController.text =
                                  notes[index][DBHelper.descColumn];
                              customBottomSheet(
                                  context: context,
                                  isEdit: true,
                                  id: notes[index][DBHelper.idColumn]);
                            },
                            icon: const Icon(Icons.edit)),
                        IconButton(
                            onPressed: () async {
                              await dbRef!
                                  .deleteNote(notes[index][DBHelper.idColumn]);
                              getNotes();
                            },
                            icon: const Icon(Icons.delete)),
                      ],
                    ),
                  ),
                );
              })
          : const Center(
              child: Text("No Data is Available"),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          customBottomSheet(context: context, isEdit: false);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

//this is a custom sheet that will be shown when we click on the floating action button
  customBottomSheet(
      {required BuildContext context, required bool isEdit, int? id}) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(20),
            // margin: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Add Note",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                      hintText: "Enter title here",
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder()),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                      hintText: "Enter descriptoin here",
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder()),
                ),
                ElevatedButton(
                    onPressed: () async {
                      final bool added = isEdit
                          ? await dbRef!.updateNote(
                              _titleController.text, _descController.text, id!)
                          : await dbRef!.addNote(
                              _titleController.text, _descController.text);
                      if (added) {
                        //this is done due to not using state management tools

                        getNotes();

                        Navigator.pop(context);
                        _descController.clear();
                        _titleController.clear();
                      }
                    },
                    child: const Text("Add Note"))
              ],
            ),
          );
        });
  }
}
