import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crud/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Firestore
  final FirestoreService firestoreService = FirestoreService();

  // Controller
  final TextEditingController textController = TextEditingController();

  // Open a dialog box to add a not
  void openNoteBox({String? docId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          // Button to save
          ElevatedButton(
            onPressed: () {
              // Add a new note
              if (docId == null) {
                firestoreService.addNotes(textController.text);
              } else {
                firestoreService.updateNote(docId, textController.text);
              }

              // Clear the text controller
              textController.clear();

              // Close the box
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        centerTitle: true,
        title: Text('NOTES CRUD'),
        backgroundColor: Colors.grey[800],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          // If we have data, get all the docs
          if (snapshot.hasData) {
            List noteList = snapshot.data!.docs;

            // Display as a list
            return ListView.builder(
              itemCount: noteList.length,
              itemBuilder: (BuildContext context, int index) {
                // Get each individual doc
                DocumentSnapshot document = noteList[index];
                String docId = document.id;

                // Get note from each doc
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];

                // Display as a list tile
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
                      child: Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ListTile(
                          title: Text(
                            noteText,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Update button
                              IconButton(
                                onPressed: () {
                                  openNoteBox(docId: docId);
                                },
                                icon: const Icon(Icons.settings),
                              ),

                              // Delete button
                              IconButton(
                                onPressed: () {
                                  firestoreService.deleteNote(docId);
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          } else {
            return const Text('No notes');
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
        backgroundColor: Colors.grey[800],
      ),
    );
  }
}
