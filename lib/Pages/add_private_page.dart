import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:image_picker/image_picker.dart';

import '../db/sql_db.dart';
import '../widgets/Private Page/my_text_filed.dart';

class AddPrivatePage extends StatefulWidget {
  const AddPrivatePage({super.key});

  @override
  State<AddPrivatePage> createState() => _AddPrivatePageState();
}

class _AddPrivatePageState extends State<AddPrivatePage> {
  GlobalKey<FormState> formState = GlobalKey();
  List<Map<String, Object?>> users = [];
  File? photo;
  TextEditingController name = TextEditingController();
  TextEditingController password = TextEditingController();
  SqlDB sqlDB = SqlDB();
  Future<void> addUser() async {
    String databasePath = await getDatabasesPath();
    String? path;
    if (photo != null) {
      path = "$databasePath/${name.text}${photo!.path.split('.').last}";
      await photo!.copy(path);
    }
    await sqlDB.insertData(from: TABLE.users, intoValues: {
      Users.name.name: name.text,
      Users.password.name: password.text,
      Users.photo.name: path,
    }).then((value) => Navigator.pop(context));
  }

  void addPhoto() async {
    XFile? imageXFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageXFile != null) setState(() => photo = File(imageXFile.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      extendBodyBehindAppBar: true,
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: formState,
            child: Column(children: [
              SizedBox(
                height: 120,
                width: 120,
                child: photo == null
                    ? TextButton(
                        onPressed: addPhoto,
                        child: const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 100,
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(photo!),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
              ),
              MYTextFiled(text: name, labelText: "Name"),
              MYTextFiled(
                text: password,
                labelText: "Password",
                obscureText: true,
              ),
              TextButton(
                onPressed: addUser,
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.blue),
                ),
                child: const Text(
                  "Add User",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
