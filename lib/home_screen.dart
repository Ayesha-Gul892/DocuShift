import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_manager/pdf_editor_screen.dart';

class Home_Screen extends StatefulWidget {
  const Home_Screen({super.key});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {

  final TextEditingController fileController = TextEditingController();

  bool fileSelected = false;

  // Keep the actual path of the picked file so we can read its content
  // and later convert it into a PDF.
  String? selectedFilePath;
  String selectedFileName = "";

  // On Flutter Web there is no real file path, only raw bytes — so we
  // always ask file_picker for bytes too (withData: true) and pass them
  // along to the editor screen.
  Uint8List? selectedFileBytes;

  void chooseFile() async {

    FilePickerResult? result =
    await FilePicker.platform.pickFiles(withData: true);

    if (result != null) {

      setState(() {
        fileController.text = result.files.single.name;
        fileSelected = true;
        selectedFilePath = result.files.single.path;
        selectedFileName = result.files.single.name;
        selectedFileBytes = result.files.single.bytes;
      });

    } else {

      setState(() {
        fileController.text = "";
        fileSelected = false;
        selectedFilePath = null;
        selectedFileName = "";
        selectedFileBytes = null;
      });

    }

  }

  // Opens the PDF editor screen where the user can edit the content and
  // then convert + share the resulting PDF.
  void goToPdfEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Pdf_Editor_Screen(
          filePath: selectedFilePath,
          fileBytes: selectedFileBytes,
          fileName: selectedFileName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,

        title: const Text(
          "DOCUFLOW",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),

        actions: const [

          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.upload_file,color: Colors.black),
          )

        ],
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            const SizedBox(height: 20),

            Card(

              elevation: 4,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              child: Padding(

                padding: const EdgeInsets.all(20),

                child: Column(

                  children: const [

                    Icon(
                      Icons.picture_as_pdf,
                      size: 80,
                      color: Colors.red,
                    ),

                    SizedBox(height: 15),

                    Text(
                      "Convert Any File to PDF",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "Choose a file and convert it into PDF instantly.",
                      textAlign: TextAlign.center,
                    )

                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            TextField(

              controller: fileController,
              readOnly: true,

              decoration: InputDecoration(

                hintText: "No file selected",

                prefixIcon: const Icon(Icons.insert_drive_file),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),

              ),
            ),

            const SizedBox(height: 20),

            SizedBox(

              width: double.infinity,
              height: 55,

              child: ElevatedButton(

                onPressed: chooseFile,

                style: ElevatedButton.styleFrom(

                  backgroundColor: Colors.black,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),

                ),

                child: const Text(
                  "Choose File",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17),
                ),

              ),

            ),

            const SizedBox(height: 20),

            SizedBox(

              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(

                icon: const Icon(Icons.picture_as_pdf),

                label: const Text(
                  "Convert to PDF",
                  style: TextStyle(fontSize: 17),
                ),

                onPressed: fileSelected ? goToPdfEditor : null,

              ),

            ),

            const SizedBox(height: 25),

            if(fileSelected)

              Container(

                width: double.infinity,

                padding: const EdgeInsets.all(15),

                decoration: BoxDecoration(

                  color: Colors.green.shade100,

                  borderRadius: BorderRadius.circular(15),

                ),

                child: Row(

                  children: const [

                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),

                    SizedBox(width: 10),

                    Expanded(

                      child: Text(
                        "File selected successfully!",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    )

                  ],
                ),
              )

          ],
        ),
      ),
    );
  }
}