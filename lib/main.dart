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

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  // Controller for the search text field
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    // Listen to search text changes
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic Query: Filter by search text if it's not empty
    Query query = FirebaseFirestore.instance.collection('notes');

    if (_searchText.isNotEmpty) {
      query = query
          .where('text', isGreaterThanOrEqualTo: _searchText)
          .where('text', isLessThanOrEqualTo: '$_searchText\uf8ff');
    } else {
      query = query.orderBy('createdAt', descending: true);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Notes"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        // Adding the Search Bar to the bottom of the AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search notes...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: query.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text("Error loading notes"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notes found."));
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

  // --- Add/Edit Dialog ---
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
            hintText: "Write your note here...",
          ),
          autofocus: true,
          maxLines: null,
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
                  await FirebaseFirestore.instance.collection('notes').add({
                    'text': controller.text,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                } else {
                  await doc.reference.update({
                    'text': controller.text,
                    'updatedAt': FieldValue.serverTimestamp(),
                  });
                }
                if (mounted) Navigator.pop(context);
              }
            },
            child: Text(doc != null ? "Update" : "Save"),
          ),
        ],
      ),
    );
  }

  // --- Delete Confirmation Dialog ---
  void _showDeleteConfirmDialog(BuildContext context, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              await doc.reference.delete();
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
