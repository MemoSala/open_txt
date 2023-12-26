// ignore_for_file: depend_on_referenced_packages, library_prefixes

import 'dart:io';

import 'package:file_picker/file_picker.dart' as filePicker;
import 'package:flutter/material.dart';
import 'package:open_txt/Pages/video_page_pc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as pathName;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:universal_platform/universal_platform.dart';

import '../model/audio_play_file_provider.dart';
import '../model/get_file_type.dart';
import '../model/screen_tools.dart';
import '../model/void_dialog.dart';
import '../widgets/Home Page/home_bottom_sheet.dart';
import 'audio_page.dart';
import 'file_page.dart';
import 'microsoft_word_page.dart';
import 'ntd_page.dart';
import 'photo_page.dart';
import 'texe_page.dart';
import '../model/counter_storage.dart';
import 'video_page_an.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.nameUser});

  final String nameUser;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with ScreenTools {
  List<File> filesPath = [];
  List<Directory> directorysPath = [];
  late String newLocalPath;
  late String newLocalPathMax;
  List<String> listLocalPath = [];

  void addFolder() =>
      VoidDialog(context, title: "Add Folder", onPressed: (String nameTxt) {
        createFolder("$newLocalPathMax/$nameTxt");
        readFilesInFolder();
      }).voidDialog();

  void uploadPhoto() async {
    XFile? imageXFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageXFile != null) {
      String path = "$newLocalPathMax/${imageXFile.name}";
      await File(imageXFile.path)
          .copy(path)
          .then((value) => openClassWidget(PhotoPage(file: File(path))));
    }
  }

  void addNTD() =>
      VoidDialog(context, title: "Add NTD", onPressed: (String nameTxt) async {
        createFolder("$newLocalPath/data_app_open_txt");
        XFile? imageXFile =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (imageXFile != null) {
          String path = "$newLocalPath/data_app_open_txt/${imageXFile.name}";
          String pathNtd = "$newLocalPathMax/$nameTxt.ntd";
          CounterStorage storage = CounterStorage(File(pathNtd));
          await storage.writeCounter("img?$path|");
          await File(imageXFile.path)
              .copy(path)
              .then((value) => openClassWidget(NTDPage(storage: storage)));
        }
      }).voidDialog();

  void addDocument() => VoidDialog(context, title: "Add Document",
          onPressed: (String nameTxt) async {
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => TexePage(
            storage: CounterStorage(
              File("$newLocalPathMax/$nameTxt.txt"),
            ),
          ),
        ));
        readFilesInFolder();
      }).voidDialog();

  void addFile() async {
    filePicker.FilePickerResult? result =
        await filePicker.FilePicker.platform.pickFiles();

    if (result != null) {
      filePicker.PlatformFile file = result.files.single;

      String path = "$newLocalPathMax/${file.name}";
      await File(file.path!).copy(path).then((value) => readFilesInFolder());
    }
  }

  void createFolder(String folderName) {
    Directory folder = Directory(folderName);
    if (!folder.existsSync()) folder.createSync(recursive: true);
  }

  void localPath() async {
    Directory directory = await getApplicationDocumentsDirectory();
    newLocalPath = "${directory.path}/${widget.nameUser}";
    readFilesInFolder();
  }

  void readFilesInFolder() {
    newLocalPathMax = newLocalPath;
    for (String stringLocalPath in listLocalPath) {
      newLocalPathMax += "/$stringLocalPath";
    }
    Directory folder = Directory(newLocalPathMax);
    if (!folder.existsSync()) folder.createSync(recursive: true);
    List<File> newFilesPath = [];
    List<Directory> newDirectorysPath = [];
    if (folder.existsSync()) {
      List<FileSystemEntity> files = folder.listSync();
      for (FileSystemEntity file in files) {
        if (file is File) {
          newFilesPath.add(file);
        } else if (file is Directory) {
          newDirectorysPath.add(file);
        }
      }
    }
    late String tNDPR = "/";
    UniversalPlatform.isWindows ? tNDPR = "\\" : tNDPR = "/";
    newDirectorysPath.remove(newDirectorysPath.firstWhere(
      (element) => "$newLocalPath${tNDPR}data_app_open_txt" == element.path,
      orElse: () => Directory("$newLocalPath${tNDPR}data_app_open_txt"),
    ));
    setState(() {
      directorysPath = newDirectorysPath;
      filesPath = newFilesPath;
      filesPath.sort((a, b) {
        int typeA = GetFileType(a.path).fileType.index;
        int typeB = GetFileType(b.path).fileType.index;
        return typeA.compareTo(typeB);
      });
    });
    if (UniversalPlatform.isAndroid) verticalScreen();
  }

  void deleteButton() => VoidDialog(context,
          title: "Delete Folder",
          child: const SizedBox(),
          text: "Delete", onPressed: (String folderName) async {
        var file = Directory(newLocalPathMax);
        await file.delete();
        setState(() => listLocalPath.removeAt(listLocalPath.length - 1));
        readFilesInFolder();
      }).voidDialog();

  void openClassWidget(Widget classWidget) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => classWidget,
    ));
    readFilesInFolder();
  }

  @override
  void initState() {
    localPath();
    super.initState();
  }

  bool showSettings = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AudioPlayFileProvider(),
      child: Scaffold(
        appBar: AppBar(
          leading: listLocalPath.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    setState(
                        () => listLocalPath.removeAt(listLocalPath.length - 1));
                    readFilesInFolder();
                  },
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                ),
          title: Text(listLocalPath.isEmpty
              ? 'Home'
              : pathName.basename(newLocalPathMax)),
          actions: [
            if (listLocalPath.isNotEmpty)
              TextButton(
                onPressed: deleteButton,
                child: const Row(children: [
                  Icon(Icons.delete_rounded),
                  Text("Delete"),
                ]),
              ),
            const SizedBox(width: 10)
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: directorysPath.isEmpty && filesPath.isEmpty
                ? const Text("No Document.")
                : body(),
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Consumer<AudioPlayFileProvider>(
              builder: (context, value, child) => value.audioPlayFile == null
                  ? const SizedBox()
                  : FloatingActionButton(
                      onPressed: value.close,
                      backgroundColor: Colors.blue.shade800,
                      child: const Icon(Icons.close_rounded),
                    ),
            ),
            const SizedBox(width: 10),
            SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              backgroundColor: Colors.blue.shade900,
              activeBackgroundColor: Colors.blue,
              overlayOpacity: 0,
              buttonSize: const Size(60.0, 60.0),
              children: [
                SpeedDialChild(
                  backgroundColor: Colors.blue.shade200,
                  labelWidget: speedDialChildToChild("Add Folder"),
                  child: const Icon(Icons.create_new_folder_rounded),
                  onTap: addFolder,
                ),
                SpeedDialChild(
                  backgroundColor: Colors.blue.shade200,
                  labelWidget: speedDialChildToChild("Add Photo"),
                  child: const Icon(Icons.add_photo_alternate),
                  onTap: uploadPhoto,
                ),
                SpeedDialChild(
                  backgroundColor: Colors.blue.shade200,
                  labelWidget: speedDialChildToChild("Add NTD"),
                  child: const Icon(Icons.art_track_rounded),
                  onTap: addNTD,
                ),
                SpeedDialChild(
                  backgroundColor: Colors.blue.shade200,
                  labelWidget: speedDialChildToChild("Add Document"),
                  child: const Icon(Icons.playlist_add_rounded),
                  onTap: addDocument,
                ),
                SpeedDialChild(
                  backgroundColor: Colors.blue.shade200,
                  labelWidget: speedDialChildToChild("Add File"),
                  child: const Icon(Icons.file_upload_rounded),
                  onTap: addFile,
                ),
              ],
            ),
          ],
        ),
        bottomSheet: const HomeBottomSheet(),
      ),
    );
  }

  Container speedDialChildToChild(String text) => Container(
        width: 110,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.blue.shade200.withOpacity(.5),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(text),
      );

  Wrap body() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: <Widget>[
            for (Directory directoryPath in directorysPath)
              box(
                filePath: directoryPath,
                icon: Icons.folder_rounded,
                onTap: () {
                  listLocalPath.add(pathName.basename(directoryPath.path));
                  readFilesInFolder();
                },
              ),
          ] +
          filesPath.map((file) {
            switch (GetFileType(file.path).fileType) {
              case FileType.video:
                return Consumer<AudioPlayFileProvider>(
                  builder: (context, value, child) => box(
                    onTap: () {
                      if (value.isPlay) {
                        value.isPlayerGoFalse();
                        value.audioPlayFile!.audioPlayer.pause();
                      }
                      openClassWidget(UniversalPlatform.isWindows
                          ? VideoPagePC(file: file)
                          : VideoPageAN(file: file));
                    },
                    filePath: file,
                    icon: Icons.video_file,
                  ),
                );
              case FileType.audio:
                return Consumer<AudioPlayFileProvider>(
                  builder: (context, value, child) => box(
                    onTap: () async {
                      if (value.isPlay) {
                        value.isPlayerGoFalse();
                        value.audioPlayFile!.audioPlayer.pause();
                      }
                      AudioPlayFile box = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AudioPage(file: file),
                        ),
                      );
                      if (box.isPlayer) {
                        if (value.isPlay) value.close();
                        value.play(box);
                        value.listen();
                      }
                      readFilesInFolder();
                    },
                    filePath: file,
                    icon: Icons.audio_file,
                  ),
                );
              case FileType.image:
                return box(
                  onTap: () => openClassWidget(PhotoPage(file: file)),
                  filePath: file,
                  child: Stack(alignment: Alignment.bottomCenter, children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.file(
                        file,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.only(bottom: 10, right: 8, left: 8),
                      decoration: const BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(4),
                        ),
                      ),
                      child: Builder(builder: (context) {
                        String path = pathName.basename(file.path);
                        String title = path.replaceRange(
                            path.length - 1 - path.split('.').last.length,
                            null,
                            "");
                        return Text(
                          title,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        );
                      }),
                    ),
                  ]),
                );
              case FileType.text:
                return box(
                  filePath: file,
                  icon: Icons.article,
                  onTap: () => openClassWidget(TexePage(
                    storage: CounterStorage(file),
                  )),
                );
              case FileType.ntd:
                return box(
                  filePath: file,
                  icon: Icons.art_track_rounded,
                  onTap: () => openClassWidget(NTDPage(
                    storage: CounterStorage(file),
                  )),
                );
              case FileType.word:
                return box(
                  filePath: file,
                  icon: Icons.picture_as_pdf_rounded,
                  onTap: () => openClassWidget(MicrosoftWordPage(file: file)),
                );
              case FileType.otherwise:
                return box(
                  filePath: file,
                  icon: Icons.insert_drive_file_rounded,
                  onTap: () => openClassWidget(
                    FilePage(file: file),
                  ),
                );
            }
          }).toList() +
          [const SizedBox(height: 80, width: double.infinity)],
    );
  }

  InkWell box({
    required FileSystemEntity filePath,
    void Function()? onTap,
    IconData? icon,
    Widget? child,
    Widget? childIcon,
  }) {
    String path = pathName.basename(filePath.path);
    late String title;
    if (filePath is File) {
      title = path.replaceRange(
          path.length - 1 - path.split('.').last.length, null, "");
    } else {
      title = path;
    }
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 130,
          width: 130,
          child: child ??
              Column(children: [
                if (icon != null)
                  Icon(
                    icon,
                    size: 100,
                    color: Colors.blue.shade900,
                  ),
                if (childIcon != null)
                  SizedBox(height: 100, width: 100, child: childIcon),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    title,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.blue.shade900),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
