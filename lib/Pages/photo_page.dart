// ignore_for_file: library_prefixes, depend_on_referenced_packages

import 'dart:io';

import 'package:flutter/material.dart';

import '../widgets/scaffold_file.dart';

class PhotoPage extends StatefulWidget {
  const PhotoPage({super.key, required, required this.file});
  final File file;
  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  bool key = false;
  double x = -187, y = -184.8;
  @override
  Widget build(BuildContext context) {
    return ScaffoldFile(
      file: widget.file,
      appBarSpacing: true,
      body: Image.file(
        widget.file,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
      ),
    );
  }
}
