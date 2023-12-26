import 'package:flutter/material.dart';

class VoidDialog {
  final String? title;
  final void Function(String) onPressed;
  final Widget? child;
  final String? text;
  final String? labelText;
  final BuildContext context;
  final bool keyAdd;

  const VoidDialog(
    this.context, {
    this.title,
    required this.onPressed,
    this.child,
    this.text,
    this.keyAdd = true,
    this.labelText,
  });

  void voidDialog() async {
    String nameTxt = "";
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.deepPurple.shade50,
        title: title == null ? null : Text(title!),
        content: child ??
            TextField(
              minLines: 1,
              maxLines: 999999999999,
              onChanged: (value) => nameTxt = value,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: labelText ?? "Type Name",
              ),
            ),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          dialogButton(
            onPressed: Navigator.of(context).pop,
            text: "Cancel",
          ),
          dialogButton(
            onPressed: () {
              if (keyAdd) Navigator.of(context).pop();
              onPressed(nameTxt);
            },
            text: text ?? "Add",
          ),
        ],
      ),
    );
  }

  ElevatedButton dialogButton({
    required void Function() onPressed,
    required String text,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Container(
        width: 50,
        height: 40,
        alignment: Alignment.center,
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
