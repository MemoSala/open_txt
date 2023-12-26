import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../widgets/scaffold_file.dart';

class MicrosoftWordPage extends StatefulWidget {
  final File file;

  const MicrosoftWordPage({super.key, required this.file});

  @override
  State<MicrosoftWordPage> createState() => _MicrosoftWordPageState();
}

class _MicrosoftWordPageState extends State<MicrosoftWordPage> {
  late PdfViewerController _pdfViewerController;
  final GlobalKey<SfPdfViewerState> _pdfSfPdfViewerState = GlobalKey();
  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ScaffoldFile(
        file: widget.file,
        body: SfPdfViewer.file(
          widget.file,
          controller: _pdfViewerController,
          key: _pdfSfPdfViewerState,
        ),
        actions: [
          IconButton(
            onPressed: () =>
                _pdfSfPdfViewerState.currentState!.openBookmarkView(),
            icon: const Icon(Icons.bookmark_rounded),
          ),
          IconButton(
            onPressed: () => _pdfViewerController.zoomLevel += 0.25,
            icon: const Icon(Icons.zoom_in_rounded),
          ),
          IconButton(
            onPressed: () => _pdfViewerController.zoomLevel -= 0.25,
            icon: const Icon(Icons.zoom_out_rounded),
          ),
        ],
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () => _pdfViewerController
                  .jumpToPage(_pdfViewerController.pageNumber - 1),
              child: const Icon(Icons.keyboard_arrow_up_rounded),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              key: _pdfSfPdfViewerState,
              onPressed: () => _pdfViewerController
                  .jumpToPage(_pdfViewerController.pageNumber + 1),
              child: const Icon(Icons.keyboard_arrow_down_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
