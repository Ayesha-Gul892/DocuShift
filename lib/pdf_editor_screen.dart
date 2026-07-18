import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

// This screen opens after the user picks a file on the Home screen.
// It lets the user EDIT the text content before it gets turned into a PDF,
// then lets them SHARE the final PDF file.
class Pdf_Editor_Screen extends StatefulWidget {
  final String? filePath;
  final Uint8List? fileBytes;
  final String fileName;

  const Pdf_Editor_Screen({
    super.key,
    required this.filePath,
    required this.fileBytes,
    required this.fileName,
  });

  @override
  State<Pdf_Editor_Screen> createState() => _Pdf_Editor_ScreenState();
}

class _Pdf_Editor_ScreenState extends State<Pdf_Editor_Screen> {
  final TextEditingController textController = TextEditingController();

  bool isLoading = true;
  bool isConverting = false;
  bool pdfReady = false;

  // On mobile/desktop we save the generated PDF to disk and keep its path.
  String? generatedPdfPath;

  // On web (and as a fallback everywhere) we keep the raw PDF bytes in
  // memory, since there is no real filesystem in the browser.
  Uint8List? generatedPdfBytes;

  @override
  void initState() {
    super.initState();
    _loadFileContent();
  }

  // Reads the picked file's content so the user can edit it.
  // - On web, file_picker only gives us bytes (no real path), so we read
  //   from widget.fileBytes first.
  // - On mobile/desktop we fall back to reading from widget.filePath.
  // Note: this treats the file as plain text. Real .docx/.pdf/.jpg files
  // are NOT plain text (a .docx is actually a zip archive), so for those
  // file types this will show garbled/empty content — that is expected.
  // Works reliably for .txt files. Type or paste text and convert normally.
  Future<void> _loadFileContent() async {
    String content = "";

    try {
      if (widget.fileBytes != null) {
        content = utf8.decode(widget.fileBytes!, allowMalformed: true);
      } else if (widget.filePath != null) {
        final file = File(widget.filePath!);
        final bytes = await file.readAsBytes();
        content = utf8.decode(bytes, allowMalformed: true);
      }
    } catch (_) {
      content = "";
    }

    // Strip characters that aren't readable text (leftover binary noise
    // from non-text files like .docx) so the box doesn't look "broken".
    final cleaned = content.replaceAll(RegExp(r'[^\x20-\x7E\n\r\t]'), '');

    setState(() {
      textController.text = cleaned.trim().isEmpty
          ? "This file type can't be read as plain text (e.g. .docx/.jpg/.pdf).\n"
          "Type or paste the content you want inside the PDF here instead."
          : cleaned;
      isLoading = false;
    });
  }

  // Builds an actual PDF document from whatever text is currently in the
  // editor. On mobile/desktop it's also saved to disk; on web it just
  // stays in memory as bytes (there is no filesystem in the browser).
  Future<void> _convertToPdf() async {
    setState(() {
      isConverting = true;
    });

    try {
      final pdfDoc = pw.Document();

      pdfDoc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Text(
              widget.fileName,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 15),
            pw.Text(
              textController.text,
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
      );

      final bytes = await pdfDoc.save();

      final baseName = widget.fileName.contains('.')
          ? widget.fileName.substring(0, widget.fileName.lastIndexOf('.'))
          : widget.fileName;

      String? savedPath;

      // path_provider (and File I/O) does not work on Flutter Web, so only
      // try to save to disk on mobile/desktop.
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
      // This ALWAYS runs, even if an error was thrown above — so the
      // button can never get stuck on "Converting..." again.
      if (mounted) {
        setState(() {
          isConverting = false;
        });
      }
    }
  }

  // Opens the native share sheet (WhatsApp, Gmail, Drive, etc.) with the
  // generated PDF attached. Works on both web and mobile/desktop.
// Opens the native share sheet (WhatsApp, Gmail, Drive, etc.) with the
  // generated PDF attached. Works on both web and mobile/desktop.
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
        text: "Sharing ${widget.fileName} converted to PDF via Docuflow",
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

  // Lets the user jump back into editing the text even after a PDF has
  // already been generated, so they can tweak it and re-convert.
  void _editAgain() {
    setState(() {
      pdfReady = false;
      generatedPdfPath = null;
      generatedPdfBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          widget.fileName,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Edit the content below before converting it to PDF:",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: textController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  enabled: !pdfReady,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (!pdfReady)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: isConverting
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.picture_as_pdf),
                  label: Text(
                    isConverting ? "Converting..." : "Convert to PDF",
                    style: const TextStyle(fontSize: 17),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: isConverting ? null : _convertToPdf,
                ),
              ),

            if (pdfReady) ...[

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "PDF ready! You can share it or edit it again.",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text(
                    "Share PDF",
                    style: TextStyle(fontSize: 17),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _sharePdf,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text(
                    "Edit Again",
                    style: TextStyle(fontSize: 17),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _editAgain,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}