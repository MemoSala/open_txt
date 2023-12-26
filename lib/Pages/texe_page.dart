// ignore_for_file: depend_on_referenced_packages, library_prefixes

import 'package:flutter/material.dart';

import '../widgets/scaffold_file.dart';
import '../model/counter_storage.dart';

class TexePage extends StatefulWidget {
  const TexePage({super.key, required this.storage});
  final CounterStorage storage;

  @override
  State<TexePage> createState() => _TexePageState();
}

class _TexePageState extends State<TexePage> {
  String dataTxt = "";
  String newDataTxt = "";
  int openWidget = 0;
  TextEditingController descriptionTEC = TextEditingController(text: "");

  Future<String> loadAsset() async {
    return await widget.storage.readCounter();
  }

  void _incrementCounter() async {
    try {
      setState(() => openWidget = 0);

      dataTxt = newDataTxt = await loadAsset();

      setState(() {
        descriptionTEC.text = dataTxt;
        openWidget = 1;
      });
    } catch (e) {
      setState(() => openWidget = 3);
    }
  }

  @override
  void initState() {
    _incrementCounter();
    super.initState();
  }

  void refresh() async {
    await widget.storage.writeCounter(newDataTxt);

    _incrementCounter();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldFile(
      file: widget.storage.file,
      isSave: dataTxt == newDataTxt,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: openWidget == 1
            ? TextField(
                controller: descriptionTEC,
                minLines: 1,
                maxLines: 999999999999,
                onChanged: (value) => setState(() => newDataTxt = value),
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'type a document...',
                ),
              )
            : Center(
                child: Text(openWidget == 3 ? "Erorr 115 ?!" : 'Loading...')),
      ),
      onPressedAction: refresh,
    );
  }
}
