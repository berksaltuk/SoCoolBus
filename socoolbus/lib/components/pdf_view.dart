import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class PDFViewerScreen extends StatefulWidget {
  final Uint8List pdfData;

  const PDFViewerScreen({super.key, required this.pdfData});

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String? _pdfPath;

  Future<void> _savePDF() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/my_pdf.pdf';
      print(filePath);
      final file = File(filePath);

      await file.writeAsBytes(widget.pdfData);

      setState(() {
        _pdfPath = filePath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF başarıyla $filePath konumuna kaydedildi.')),
      );
    } catch (e) {
      print('Error saving PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF kaydedilemedi!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF'),
      ),
      body: Stack(
        children: [
          PDFView(
            pdfData: widget.pdfData,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                onPressed: _savePDF,
                child: const Icon(Icons.save),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
