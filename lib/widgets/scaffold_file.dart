// ignore_for_file: depend_on_referenced_packages, library_prefixes

import 'dart:io';

import 'package:flutter/material.dart';

import '../model/popup_menu_widget.dart';
import '../model/void_dialog.dart';
import 'package:path/path.dart' as pathName;

class ScaffoldFile extends StatefulWidget {
  final File file;
  final bool isSave;
  final bool isAppBar;
  final bool appBarSpacing;

  final void Function()? onPressedAction;
  final void Function()? leading;
  final Widget? body;
  final Widget? floatingActionButton;
  final List<Widget> actions;
  const ScaffoldFile({
    super.key,
    required this.file,
    this.body,
    this.isSave = true,
    this.isAppBar = true,
    this.appBarSpacing = false,
    this.onPressedAction,
    this.actions = const [],
    this.floatingActionButton,
    this.leading,
  });

  @override
  State<ScaffoldFile> createState() => _ScaffoldFileState();
}

class _ScaffoldFileState extends State<ScaffoldFile> with PopupMenuMixin {
  late int size;
  late String title;

  void initStateFuture() async {
    String path = pathName.basename(widget.file.path);
    title = path.replaceRange(
        path.length - 1 - path.split('.').last.length, null, "");
    size = await widget.file.length();
    size ~/= 1024;
  }

  @override
  void initState() {
    initStateFuture();
    super.initState();
  }

  void information() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.deepPurple.shade50,
        title: const Center(child: Text("Information")),
        content: SizedBox(
          height: 300,
          width: 200,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                informationText(title: "Name: ", text: title),
                informationText(title: "Path: ", text: widget.file.path),
                informationText(
                  title: "Size: ",
                  text: size < 1024
                      ? "${size}KB"
                      : size ~/ 1024 < 1024
                          ? "${(size ~/ 10.24) / 100}MB"
                          : "${((size ~/ 1024) ~/ 10.24) / 100}GB",
                ),
              ],
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          ElevatedButton(
            onPressed: Navigator.of(context).pop,
            child: Container(
              width: 50,
              height: 40,
              alignment: Alignment.center,
              child: const Text("Cancel", textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }

  Padding informationText({required String title, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text.rich(TextSpan(children: [
        TextSpan(
          text: title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(text: text),
      ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.appBarSpacing ? Colors.black : null,
      extendBodyBehindAppBar: widget.appBarSpacing,
      appBar: widget.isAppBar
          ? AppBar(
              foregroundColor: widget.appBarSpacing ? Colors.white : null,
              leading: IconButton(
                onPressed: widget.leading ??
                    () {
                      if (widget.isSave) {
                        Navigator.of(context).pop();
                      } else {
                        VoidDialog(
                          context,
                          onPressed: (vol) => Navigator.of(context).pop(),
                          child: const SizedBox(),
                          title: "Are you sure, don't you save edit?",
                          text: "Ok",
                        ).voidDialog();
                      }
                    },
                icon: const Icon(Icons.arrow_back_ios_rounded),
              ),
              title: Text(title),
              actions: widget.actions +
                  [
                    PopupMenuButton<String>(
                      onSelected: (String text) => text == "Information"
                          ? information()
                          : VoidDialog(
                              context,
                              onPressed: (vlo) async {
                                Navigator.of(context).pop();
                                await widget.file.delete();
                              },
                              child: const SizedBox(),
                              title: "Are You Sure Delete This File?",
                              text: "Delete",
                            ).voidDialog(),
                      itemBuilder: (BuildContext context) => [
                        PopupMenuWidget(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              popupMenuButton(context, text: "Information"),
                              popupMenuButton(context, text: "Delete"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                  ],
            )
          : null,
      body: widget.body,
      floatingActionButton: widget.floatingActionButton ??
          (widget.isSave
              ? null
              : FloatingActionButton(
                  onPressed: widget.onPressedAction,
                  tooltip: 'Save',
                  child: const Icon(Icons.save_as_rounded),
                )),
    );
  }
}
