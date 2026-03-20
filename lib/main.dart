import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Advanced Note App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NoteListScreen(),
    );
  }
}

class NoteListScreen extends StatelessWidget {
  const NoteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Firebase Notes"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('notes')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error!"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("තවම සටහන් කිසිවක් නැත."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(data['text'] ?? ""),
                  subtitle: Text(
                    data['createdAt'] != null
                        ? (data['createdAt'] as Timestamp)
                              .toDate()
                              .toString()
                              .split('.')[0]
                        : "",
                  ),
                  // නෝට් එක උඩ ටැප් කළාම Edit කරන්න පුළුවන්
                  onTap: () => _showAddNoteDialog(context, doc: doc),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmDialog(context, doc),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- නෝට් එකක් ඇතුළත් කිරීමට හෝ සංස්කරණය කිරීමට (Add/Edit) ---
  void _showAddNoteDialog(BuildContext context, {DocumentSnapshot? doc}) {
    final TextEditingController controller = TextEditingController(
      text: doc != null ? doc['text'] : "",
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doc != null ? "Edit Note" : "Add New Note"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "ඔබේ සටහන මෙතැන ලියන්න...",
          ),
          autofocus: true,
          maxLines: null, // පේළි කිහිපයක් ලියන්න පුළුවන් වෙන්න
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                if (doc == null) {
                  // අලුත් එකක් එකතු කිරීම
                  await FirebaseFirestore.instance.collection('notes').add({
                    'text': controller.text,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                } else {
                  // පරණ එකක් Update කිරීම
                  await doc.reference.update({
                    'text': controller.text,
                    'updatedAt': FieldValue.serverTimestamp(),
                  });
                }
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(doc != null ? "Update" : "Save"),
          ),
        ],
      ),
    );
  }

  // --- මකන්න කලින් ඇසීමට (Delete Confirmation) ---
  void _showDeleteConfirmDialog(BuildContext context, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("ඔබට විශ්වාසද මෙම සටහන මැකීමට අවශ්‍ය බව?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              await doc.reference.delete();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
