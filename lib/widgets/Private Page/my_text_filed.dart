import 'package:flutter/material.dart';

class MYTextFiled extends StatefulWidget {
  const MYTextFiled({
    Key? key,
    required this.text,
    required this.labelText,
    this.obscureText = false,
  }) : super(key: key);

  final TextEditingController text;
  final String labelText;
  final bool obscureText;

  @override
  State<MYTextFiled> createState() => _MYTextFiledState();
}

class _MYTextFiledState extends State<MYTextFiled> {
  FocusNode focusNode = FocusNode();
  bool isFocus = false;

  @override
  void initState() {
    focusNode.addListener(() {
      setState(() => isFocus = focusNode.hasFocus);
    });
    super.initState();
  }

  @override
  void dispose() {
    focusNode.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextFormField(
        focusNode: focusNode,
        obscureText: widget.obscureText,
        controller: widget.text,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(10),
          border: const OutlineInputBorder(),
          labelText: widget.labelText,
        ),
      ),
    );
  }
}
