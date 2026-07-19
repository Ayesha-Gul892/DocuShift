import 'dart:typed_data';
import 'package:docushift/pdf_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:docushift/services/hive_services.dart';
import 'package:docushift/saved_files_screen.dart';

class Home_Screen extends StatefulWidget {
  const Home_Screen({super.key});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {

  final HiveService hiveService = HiveService();


  final TextEditingController fileController = TextEditingController();

  bool fileSelected = false;

  String? selectedFilePath;
  String selectedFileName = "";

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

  void goToPdfEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfEditorScreen(
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


      backgroundColor: Colors.white,

      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [

            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.blue,
                  Colors.blue.shade200,
                ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                ),
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                      size: 35,
                    ),
                  ),

                  SizedBox(height: 15),

                  Text(
                    "DOCUSHIFT",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "Manage Your Files",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),

                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.save),
              title: const Text("Saved Files"),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SavedFilesScreen(),
                  ),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About"),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "DocuShift",
                  applicationVersion: "1.0",

                  children: const [

                    SizedBox(height: 10),

                    Text(
                      "DocuShift is a file conversion application that allows users to convert CSV and TXT files into PDF format. It also provides CSV editing, PDF sharing, and local file saving using Hive.",
                    ),

                  ],
                );
              },
            ),

          ],
        ),
      ),

      appBar: AppBar(

        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),


        backgroundColor: Colors.blue,
        elevation: 4,
        centerTitle: true,

        title: const Text(
          "DOCUSHIFT",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),

        actions: const [

          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.upload_file,color: Colors.white),
          )

        ],
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            const SizedBox(height: 20),


            // MAIN CONVERTER CARD

            Container(

              margin: const EdgeInsets.symmetric(horizontal: 5),

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius: BorderRadius.circular(20),

                boxShadow: const [

                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0,5),
                  ),

                ],

              ),


              child: Column(

                children: [


                  Row(

                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                    children: [


                      Image.asset(
                        "assets/image/csv-file.jpg",
                        height: 80,
                      ),


                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.blue,
                        size: 40,
                      ),


                      const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                        size: 80,
                      ),

                    ],

                  ),



                  const SizedBox(height: 20),



                  const Text(

                    "Fast • Secure • Simple",

                    style: TextStyle(

                      fontSize: 24,

                      fontWeight: FontWeight.bold,

                    ),

                  ),



                  const SizedBox(height: 10),



                  const Text(

                    "Easily convert your files into PDF documents",

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.white,
                    ),

                  ),


                ],

              ),

            ),



            const SizedBox(height: 30),



            // FILE FIELD


            TextField(

              controller: fileController,

              readOnly: true,


              decoration: InputDecoration(

                hintText: "No file selected",

                filled: true,

                fillColor: Colors.white,


                prefixIcon: const Icon(
                  Icons.insert_drive_file,
                ),


                suffixIcon: const Icon(
                  Icons.folder,
                ),


                border: OutlineInputBorder(

                  borderRadius: BorderRadius.circular(15),

                ),

              ),

            ),



            const SizedBox(height: 20),



            // CHOOSE BUTTON


            SizedBox(

              width: double.infinity,

              height: 55,


              child: ElevatedButton.icon(

                onPressed: chooseFile,


                icon: const Icon(
                  Icons.folder_open,
                  color: Colors.white,
                ),


                label: const Text(

                  "Choose File",

                  style: TextStyle(

                    color: Colors.white,

                    fontSize: 18,

                  ),

                ),



                style: ElevatedButton.styleFrom(

                  backgroundColor: Colors.black,


                  shape: RoundedRectangleBorder(

                    borderRadius: BorderRadius.circular(15),

                  ),

                ),

              ),

            ),



            const SizedBox(height: 15),

            // CONVERT BUTTON


            SizedBox(

              width: double.infinity,

              height: 55,


              child: ElevatedButton.icon(

                onPressed: fileSelected
                    ? goToPdfEditor
                    : null,


                icon: const Icon(

                  Icons.picture_as_pdf,

                  color: Colors.white,

                ),


                label: const Text(

                  "Convert to PDF",

                  style: TextStyle(

                    color: Colors.white,

                    fontSize: 18,

                  ),

                ),



                style: ElevatedButton.styleFrom(

                  backgroundColor: Colors.blue[300],


                  shape: RoundedRectangleBorder(

                    borderRadius: BorderRadius.circular(15),

                  ),

                ),

              ),

            ),



            const SizedBox(height: 20),



            // SUCCESS MESSAGE


            if(fileSelected)

              Container(

                width: double.infinity,

                padding: const EdgeInsets.all(15),


                decoration: BoxDecoration(

                  color: Colors.green.shade100,

                  borderRadius: BorderRadius.circular(15),

                ),


                child: const Row(

                  children: [


                    Icon(

                      Icons.check_circle,

                      color: Colors.green,

                    ),


                    SizedBox(width: 10),


                    Text(

                      "File selected successfully!",

                      style: TextStyle(

                        fontWeight: FontWeight.bold,

                      ),

                    )

                  ],

                ),

              ),



          ],

        ),

      ),
    );
  }
}