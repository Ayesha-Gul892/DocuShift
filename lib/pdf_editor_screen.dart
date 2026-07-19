import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:docushift/services/hive_services.dart';
import 'package:excel/excel.dart';


class PdfEditorScreen extends StatefulWidget {

  final String? filePath;
  final Uint8List? fileBytes;
  final String fileName;

  const PdfEditorScreen({
    super.key,
    required this.filePath,
    required this.fileBytes,
    required this.fileName,

  });

  @override
  State<PdfEditorScreen> createState() => _PdfEditorScreenState();
}

class _PdfEditorScreenState extends State<PdfEditorScreen> {
  final HiveService hiveService = HiveService();

  bool isConverting = false;
  bool pdfReady = false;
  String? generatedPdfPath;

  Uint8List? generatedPdfBytes;

  Future<void> _convertToPdf() async {
    setState(() {
      isConverting = true;
    });

    try {
      final pdfDoc = pw.Document();

      // IMAGE
      if (widget.fileName.toLowerCase().endsWith(".jpg") ||
          widget.fileName.toLowerCase().endsWith(".jpeg") ||
          widget.fileName.toLowerCase().endsWith(".png")) {

        final image = pw.MemoryImage(widget.fileBytes!);

        pdfDoc.addPage(
          pw.Page(
            build: (context) => pw.Center(
              child: pw.Image(image),
            ),
          ),
        );
      }

      // CSV
      else if (widget.fileName.toLowerCase().endsWith(".csv")) {

        String csvText = utf8.decode(widget.fileBytes!);

        pdfDoc.addPage(
          pw.MultiPage(
            build: (context) => [
              pw.Text(csvText),
            ],
          ),
        );
      }
// XLSX
      else if (widget.fileName.toLowerCase().endsWith(".xlsx")) {

        var excelFile = Excel.decodeBytes(widget.fileBytes!);

        List<List<String>> tableData = [];

        for (var sheet in excelFile.tables.keys) {

          var rows = excelFile.tables[sheet]!.rows;

          for (var row in rows) {

            List<String> cleanRow = row
                .map((cell) => cell?.value.toString().trim() ?? "")
                .toList();

            // Empty columns remove karo
            while (cleanRow.isNotEmpty && cleanRow.last.isEmpty) {
              cleanRow.removeLast();
            }
            cleanRow.removeWhere((element) => element.isEmpty);

            // Empty rows skip karo
            if (cleanRow.any((element) => element.isNotEmpty)) {
              tableData.add(cleanRow);
            }
          }
        }

        pdfDoc.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (context) {

              return [

                pw.Text(
                  "Excel Data",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 20),

                pw.Table.fromTextArray(
                  headers: tableData.first,
                  data: tableData.sublist(1),

                  border: pw.TableBorder.all(),

                  cellStyle: const pw.TextStyle(
                    fontSize: 7,
                  ),

                  headerStyle: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

              ];
            },
          ),
        );
      }
      final bytes = await pdfDoc.save();

      final baseName = "PDF_${DateTime.now().millisecondsSinceEpoch}";

      String? savedPath;

      if (!kIsWeb) {
        final outputDir = await getApplicationDocumentsDirectory();
        savedPath = "${outputDir.path}/$baseName.pdf";
        final pdfFile = File(savedPath);
        await pdfFile.writeAsBytes(bytes);
      }
      setState(() {
        generatedPdfBytes = bytes;
        generatedPdfPath = savedPath;
        pdfReady = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PDF generated successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Conversion failed: $e")),
        );
      }
    } finally {

      if (mounted) {
        setState(() {
          isConverting = false;
        });
      }
    }
  }

  Future<void> _sharePdf() async {
    if (generatedPdfBytes == null && generatedPdfPath == null) return;

    final baseName = widget.fileName.contains('.')
        ? widget.fileName.substring(0, widget.fileName.lastIndexOf('.'))
        : widget.fileName;

    try {
      final XFile fileToShare;

      if (!kIsWeb && generatedPdfPath != null) {
        fileToShare = XFile(generatedPdfPath!);
      } else {
        fileToShare = XFile.fromData(
          generatedPdfBytes!,
          name: "$baseName.pdf",
          mimeType: "application/pdf",
        );
      }

      await Share.shareXFiles(
        [fileToShare],
        text: "Sharing ${widget.fileName} converted to PDF via DocuShift",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PDF shared successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Share failed: $e")),
        );
      }
    }
  }

  void _saveFile() {

    if (generatedPdfPath == null) return;

    hiveService.saveFile(
      widget.fileName,
      generatedPdfPath!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Saved Successfully"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,

      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 40),

            const Icon(
              Icons.picture_as_pdf,
              size: 100,
              color: Colors.red,
            ),

            const SizedBox(height: 20),

            Text(
              widget.fileName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            if (!pdfReady)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Convert to PDF"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _convertToPdf,
                ),
              ),

            if (pdfReady) ...[

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[300],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _saveFile,
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text("Share PDF"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[300],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _sharePdf,
                ),
              ),

            ],

          ],
        ),
      ),
    );
  }
}