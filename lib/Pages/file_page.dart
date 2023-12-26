// ignore_for_file: depend_on_referenced_packages, library_prefixes

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as pathName;

import '../widgets/scaffold_file.dart';
import '../model/get_file_type.dart';

class FilePage extends StatelessWidget {
  const FilePage({super.key, required this.file});
  final File file;
  @override
  Widget build(BuildContext context) {
    final String getFileExtension = GetFileType(file.path).getFileExtension;
    late String icon;
    switch (getFileExtension) {
      case "xlsx":
        icon = "assets/image/xlsx.png";
        break;
      case "docx":
        icon = "assets/image/docx.png";
        break;
      default:
        icon = "file";
        break;
    }
    return ScaffoldFile(
      file: file,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: icon == "file"
                  ? const Icon(
                      Icons.insert_drive_file_rounded,
                      size: 300,
                    )
                  : Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Image.asset(
                        icon,
                        height: 250,
                      ),
                    )),
          Text(
            pathName.basename(file.path),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              height: 1,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            file.path,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          )
        ],
      ),
    );
  }
}
