import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crud/services/firestore_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // firestore
  final FirestoreService firestoreService = FirestoreService();

  // text controller
  final TextEditingController textController = TextEditingController();

  // open a dialog box to add a note
  void openNoteBox({String? docID}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            // user input
            content: TextField(
              controller: textController,
            ),
            actions: [
              // save button
              ElevatedButton(
                onPressed: () {
                  // add a new note
                  if (docID == null) {
                    firestoreService.addNote(textController.text);
                  }
                  // update an existing note
                  else {
                    firestoreService.updateNote(docID, textController.text);
                  }

                  // clear the text controller
                  textController.clear();

                  // close the dialog box
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase CRUD'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          // if we have data, get all the docs
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            // display as a list
            return ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                // get each individual doc
                DocumentSnapshot document = notesList[index];
                String docID = document.id;

                // get note from each doc
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];

                // display as a list tile
                return ListTile(
                    title: Text(noteText),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => openNoteBox(docID: docID),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () => firestoreService.deleteNote(docID),
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ));
              },
            );
          }

          // if there is no data, return nothing
          else {
            return const Text('No notes...');
          }
        },
      ),
    );
  }
}
