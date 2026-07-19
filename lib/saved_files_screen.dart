import 'package:flutter/material.dart';
import 'package:docushift/services/hive_services.dart';
import 'package:open_file/open_file.dart';
class SavedFilesScreen extends StatefulWidget {
  const SavedFilesScreen({super.key});

  @override
  State<SavedFilesScreen> createState() => _SavedFilesScreenState();
}

class _SavedFilesScreenState extends State<SavedFilesScreen> {
  final HiveService hiveService = HiveService();

  @override
  Widget build(BuildContext context) {
    final files = hiveService.getFiles();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Files"),
      ),
      body: files.isEmpty
          ? const Center(
        child: Text(
          "No Saved Files",
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          final key = files.keys.elementAt(index);

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              onTap: () {
                OpenFile.open(files[key]);
              },

              leading: const Icon(Icons.insert_drive_file),
              title: Text(key),
              subtitle: Text(files[key]),

              trailing: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),

                onPressed: () async {
                  bool? delete = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Delete File"),
                        content: const Text(
                          "Are you sure you want to delete this file?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text("Cancel"),
                          ),

                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text("Delete"),
                          ),
                        ],
                      );
                    },
                  );

                  if (delete == true) {
                    hiveService.deleteFile(key);
                    setState(() {});
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}