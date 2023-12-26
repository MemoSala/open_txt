import 'package:flutter/material.dart';

class PopupMenuWidget<T> extends PopupMenuEntry<T> {
  const PopupMenuWidget({super.key, required this.child});

  final Widget child;

  @override
  State<PopupMenuWidget> createState() => _PopupMenuWidgetState();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PopupMenuWidgetState extends State<PopupMenuWidget> {
  @override
  Widget build(BuildContext context) => widget.child;
}

mixin PopupMenuMixin {
  InkWell popupMenuButton(context, {required String text}) {
    return InkWell(
      onTap: () => Navigator.pop(context, text),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(4.0),
        alignment: Alignment.center,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
