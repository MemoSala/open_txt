import 'dart:io';

class CounterStorage {
  CounterStorage(this.file);
  final File file;

  Future<String> readCounter() async {
    try {
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      return "";
    }
  }

  Future<File> writeCounter(String counter) async =>
      await file.writeAsString(counter);
}
