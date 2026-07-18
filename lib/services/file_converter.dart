import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:open_file/open_file.dart';

class FileConverter {
  // Text file ko PDF me convert karta hai
  Future<String> convertTxtToPdf(String filePath) async {
    // 1. TXT file ka content read karo
    final file = File(filePath);
    final content = await file.readAsString();

    // 2. Naya PDF document banao
    final pdf = pw.Document();

    // 3. PDF me ek page add karo, content usme likho
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Text(content);
        },
      ),
    );

    // 4. PDF ko save karne ke liye phone ka folder path lo
    final outputDir = await getApplicationDocumentsDirectory();
    final outputPath = "${outputDir.path}/converted_output.pdf";

    // 5. PDF ko file me save karo
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(await pdf.save());

    // 6. Saved PDF ka path wapas bhejo
    return outputPath;
  }

  // CSV file ko PDF table me convert karta hai
  Future<String> convertCsvToPdf(String filePath) async {
    // 1. CSV file ka raw content read karo
    final file = File(filePath);
    final content = await file.readAsString();

    // 2. CSV text ko rows/columns (List of Lists) me convert karo
    List<List<dynamic>> rows = CsvToListConverter().convert(content);

    // 3. Naya PDF document banao
    final pdf = pw.Document();

    // 4. PDF me table format me data likho
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.TableHelper.fromTextArray(data: rows);
        },
      ),
    );

    // 5. Save karne ke liye path lo
    final outputDir = await getApplicationDocumentsDirectory();
    final outputPath = "${outputDir.path}/converted_output.pdf";

    // 6. PDF save karo
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(await pdf.save());

    return outputPath;
  }

  // Image (JPG/PNG) ko PDF me convert karta hai
  Future<String> convertImageToPdf(String filePath) async {
    // 1. Image file ko bytes me read karo
    final imageFile = File(filePath);
    final imageBytes = await imageFile.readAsBytes();
    final image = pw.MemoryImage(imageBytes);

    // 2. Naya PDF document banao
    final pdf = pw.Document();

    // 3. PDF page me image fit karo
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Center(child: pw.Image(image));
        },
      ),
    );

    // 4. Save karo
    final outputDir = await getApplicationDocumentsDirectory();
    final outputPath = "${outputDir.path}/converted_output.pdf";
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(await pdf.save());

    return outputPath;
  }

  // File type check karke sahi function call karta hai (MAIN FUNCTION)
  Future<String> convertFile(String filePath) async {
    // 1. File ka extension nikaalo (chhote letters me)
    final extension = filePath.split('.').last.toLowerCase();

    // 2. Extension ke hisaab se sahi function call karo
    if (extension == 'csv') {
      return await convertCsvToPdf(filePath);
    } else if (extension == 'txt') {
      return await convertTxtToPdf(filePath);
    } else if (extension == 'jpg' ||
        extension == 'jpeg' ||
        extension == 'png') {
      return await convertImageToPdf(filePath);
    } else if (extension == 'pdf') {
      // agar already PDF hai, to seedha usi ka path wapas kar do
      return filePath;
    } else {
      // koi aur file type (docx, exe, video, etc)
      throw Exception("This file type is not supported yet: .$extension");
    }
  }
}
