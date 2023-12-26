import 'dart:io';

import 'package:flutter/material.dart';

import '../model/popup_menu_widget.dart';
import '../widgets/scaffold_file.dart';
import '../model/counter_storage.dart';

import '../model/void_dialog.dart';

class NTDPage extends StatefulWidget {
  const NTDPage({super.key, required this.storage});
  final CounterStorage storage;

  @override
  State<NTDPage> createState() => _NTDPageState();
}

class _NTDPageState extends State<NTDPage> with PopupMenuMixin {
  String dataTxt = "";
  String newDataTxt = "";
  int openWidget = 0;

  Future<String> loadAsset() async {
    return await widget.storage.readCounter();
  }

  void _incrementCounter() async {
    try {
      setState(() => openWidget = 0);

      dataTxt = newDataTxt = await loadAsset();

      setState(() {
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

  void edit(String value) => setState(() => newDataTxt += value);

  @override
  Widget build(BuildContext context) {
    return ScaffoldFile(
      file: widget.storage.file,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: openWidget == 1
            ? readNTD()
            : Center(
                child: Text(openWidget == 3 ? "Erorr 115 ?!" : 'Loading...'),
              ),
      ),
      isSave: dataTxt == newDataTxt,
      onPressedAction: refresh,
    );
  }

  List<DataNtd> ndtList = [];
  Widget readNTD() {
    ndtList = [];
    String textNew = newDataTxt;
    int length = 0;
    for (int i = 0; i < textNew.length; i++) {
      if (textNew[i] == "?") length++;
    }
    for (int i = 0; i < length; i++) {
      String tn1 = textNew.split('?').first;
      textNew = textNew.replaceFirst("$tn1?", "");
      String tn2 = textNew.split('|').first;
      textNew = textNew.replaceFirst("$tn2|", "");
      ndtList.add(DataNtd(name: tn1, data: tn2));
    }
    List<Widget> ndtWidget = [];
    for (DataNtd ndt in ndtList) {
      ndtWidget.addAll([
        ndt.name == "img"
            ? File(ndt.data).existsSync()
                ? Image.file(File(ndt.data), fit: BoxFit.fitWidth)
                : Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: Transform.translate(
                        offset: const Offset(0, -5),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red.shade700,
                          size: 100,
                        ),
                      ),
                    ),
                  )
            : Row(children: [
                Container(
                  width: 80,
                  padding: const EdgeInsets.all(5.5),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade300,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    ndt.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(child: Text(ndt.data)),
                PopupMenuButton<String>(
                  onSelected: (String text) => text == "Edit"
                      ? voidDialog(
                          onTap: (value) => setState(() => newDataTxt =
                              newDataTxt.replaceFirst(
                                  "${ndt.name}?${ndt.data}|", value)),
                          nameDataTxt: ndt.name,
                          dataTxt: ndt.data,
                        )
                      : setState(() => newDataTxt = newDataTxt.replaceFirst(
                          "${ndt.name}?${ndt.data}|", "")),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuWidget(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          popupMenuButton(context, text: "Edit"),
                          popupMenuButton(context, text: "Delete"),
                        ],
                      ),
                    ),
                  ],
                ),
              ]),
        const Divider(),
      ]);
    }
    ndtWidget.addAll([
      GestureDetector(
        onTap: () => voidDialog(onTap: edit),
        child: Container(
          height: 30,
          width: 80,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.orange.shade300,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.add),
        ),
      ),
      const SizedBox(height: 100)
    ]);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ndtWidget,
      ),
    );
  }

  void voidDialog({
    required void Function(String) onTap,
    String nameDataTxt = "",
    String dataTxt = "",
  }) {
    String newNameDataTxt = nameDataTxt;
    String newDataTxt = dataTxt;
    final GlobalKey<FormState> formState = GlobalKey();
    VoidDialog(
      context,
      onPressed: (vlo) {
        FormState? formData = formState.currentState;
        if (formData!.validate()) {
          Navigator.of(context).pop();
          onTap("$newNameDataTxt?$newDataTxt|");
        }
      },
      keyAdd: false,
      child: SizedBox(
        height: 164,
        child: Form(
          key: formState,
          child: Column(
            children: [
              TextFormField(
                controller: TextEditingController(text: newNameDataTxt),
                maxLength: 8,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please write name data in the box.";
                  } else {
                    return null;
                  }
                },
                onChanged: (value) => setState(() => newNameDataTxt = value),
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Type Name Data",
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: TextEditingController(text: newDataTxt),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please write something in the box.";
                  } else {
                    return null;
                  }
                },
                onChanged: (value) => setState(() => newDataTxt = value),
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Type Data",
                ),
              ),
            ],
          ),
        ),
      ),
    ).voidDialog();
  }
}

class DataNtd {
  final String name, data;
  const DataNtd({required this.name, required this.data});
}
