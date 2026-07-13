import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'services/file_converter.dart';

class Home_Screen extends StatefulWidget {
  const Home_Screen({super.key});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  final TextEditingController fileController = TextEditingController();
  String? selectedFilePath; // file ka path store karega

  void chooseFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFilePath = result.files.single.path;
        fileController.text = result.files.single.name;
      });
    } else {
      setState(() {
        fileController.text = "No file selected";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 30,
                  left: 20,
                  right: 20,
                  bottom: 40,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade100, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(1000),
                    bottomRight: Radius.circular(1000),
                  ),
                ),

                child: const Column(
                  children: [
                    Text(
                      "DOCUSHIFT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "Convert CSV Files to PDF",
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // CARD
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset("assets/image/csv-file.jpg", height: 80),

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
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Easily convert your CSV files into PDF documents",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // FILE FIELD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: TextField(
                  controller: fileController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "No file selected",
                    filled: true,
                    fillColor: Colors.white,

                    prefixIcon: const Icon(Icons.insert_drive_file),
                    suffixIcon: const Icon(Icons.folder),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //CHOOSE BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton.icon(
                    onPressed: chooseFile,

                    icon: const Icon(Icons.folder_open, color: Colors.white),

                    label: const Text(
                      "Choose CSV File",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // CONVERT BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (selectedFilePath == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select a file first"),
                          ),
                        );
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Converting... please wait"),
                        ),
                      );

                      try {
                        final converter = FileConverter();
                        final pdfPath = await converter.convertFile(
                          selectedFilePath!,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("PDF created at: $pdfPath")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: ${e.toString()}")),
                        );
                      }
                    },

                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),

                    label: const Text(
                      "Convert to PDF",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget featureCard(IconData icon, String title) {
    return Expanded(
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue, size: 40),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
