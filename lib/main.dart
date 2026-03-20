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
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const NoteListScreen(),
    );
  }
}

class NoteListScreen extends StatelessWidget {
  const NoteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Firebase Notes"), centerTitle: true),
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
                  // Note එක උඩ ක්ලික් කළාම Edit කරන්න dialog එක open වෙයි
                  onTap: () => _showAddNoteDialog(context, doc: doc),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => doc.reference.delete(),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showAddNoteDialog(context), // අලුත් එකක් නිසා doc යවන්නේ නැහැ
        child: const Icon(Icons.add),
      ),
    );
  }

  // මෙන්න වෙනස් කළ Function එක
  void _showAddNoteDialog(BuildContext context, {DocumentSnapshot? doc}) {
    // Edit කරනවා නම් පරණ text එක controller එකට දානවා
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
                  // අලුත් Note එකක් එකතු කිරීම
                  await FirebaseFirestore.instance.collection('notes').add({
                    'text': controller.text,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                } else {
                  // තියෙන Note එකක් Update කිරීම
                  await doc.reference.update({
                    'text': controller.text,
                    // කාලයත් update වෙන්න ඕන නම් විතරක් මේක දාන්න
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
}
