import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_txt/Pages/home_page.dart';

import '../db/sql_db.dart';
import '../model/void_dialog.dart';
import 'add_private_page.dart';

class PrivatePage extends StatefulWidget {
  const PrivatePage({super.key});

  @override
  State<PrivatePage> createState() => _PrivatePageState();
}

class _PrivatePageState extends State<PrivatePage> {
  SqlDB sqlDB = SqlDB();
  List<User> users = [];

  void readUsers() async {
    List<Map<String, Object?>> newUsers =
        await sqlDB.readData(from: TABLE.users, select: "*");
    setState(() {
      users = [];
      users.addAll(newUsers.map(
        (e) => User(
          e[Users.password.name] as String,
          name: e[Users.name.name] as String,
          photo: e[Users.photo.name] as String?,
        ),
      ));
    });
  }

  @override
  void initState() {
    readUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(children: [
            for (User user in users)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  title: Text(user.name),
                  onTap: VoidDialog(
                    context,
                    onPressed: (p0) {
                      if (p0 == user.password) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => HomePage(nameUser: user.name),
                        ));
                      }
                    },
                    text: "Open",
                    title: 'Open "${user.name}"',
                    labelText: "Password",
                  ).voidDialog,
                  leading: Container(
                    height: 50,
                    width: 50,
                    foregroundDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: user.photo != null
                          ? DecorationImage(
                              image: FileImage(File(user.photo!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: const Icon(
                      Icons.photo_outlined,
                      color: Colors.black54,
                      size: 40,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () async {
                      await sqlDB.deleteData(
                        from: TABLE.users,
                        where: "${Users.name.name} = '${user.name}'",
                      );
                      readUsers();
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(3),
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AddPrivatePage(),
                  ));
                  readUsers();
                },
                title: const Icon(
                  Icons.add,
                  color: Colors.black54,
                  size: 30,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
