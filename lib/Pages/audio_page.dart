// ignore_for_file: depend_on_referenced_packages, library_prefixes

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

import '../model/audio_play_file_provider.dart';
import '../widgets/scaffold_file.dart';

class AudioPage extends StatefulWidget {
  const AudioPage({super.key, required this.file, this.aPF});
  final File file;
  final AudioPlayFile? aPF;

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  late AudioPlayFile? aPF;
  bool openPage = false;

  @override
  void initState() {
    voidInitState();
    super.initState();
  }

  void voidInitState() async {
    if (widget.aPF == null) {
      Metadata metadata = await MetadataRetriever.fromFile(widget.file);
      AudioPlayer audioPlayer = AudioPlayer();
      await audioPlayer.setSource(DeviceFileSource(widget.file.path));
      Duration duration = await audioPlayer.onDurationChanged.first;
      setState(
        () => aPF = AudioPlayFile(
          audioPlayer: audioPlayer,
          isPlayer: false,
          metadata: metadata,
          duration: duration,
          position: Duration.zero,
          file: widget.file,
        ),
      );
      await aPF!.audioPlayer.setSource(DeviceFileSource(widget.file.path));
    } else {
      aPF = widget.aPF;
    }
    aPF!.listen = aPF!.audioPlayer.onPositionChanged.listen((event) {
      setState(() => aPF!.position = event);
      if (aPF!.position == aPF!.duration) {
        setState(() => aPF!.isPlayer = false);
      }
    });
    setState(() => openPage = true);
  }

  String timeVideo(Duration position) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");

    return [
      if (aPF!.duration.inHours > 0) twoDigits(position.inHours),
      twoDigits(position.inMinutes.remainder(60)),
      twoDigits(position.inSeconds.remainder(60)),
    ].join(":");
  }

  @override
  void dispose() {
    voidDispose();
    super.dispose();
  }

  void voidDispose() async {
    if (!aPF!.isPlayer && widget.aPF == null) {
      await aPF!.listen!.cancel();
      await aPF!.audioPlayer.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldFile(
      file: widget.file,
      leading: () async {
        if (openPage) {
          await aPF!.listen!
              .cancel()
              .then((value) => Navigator.of(context).pop(aPF));
        }
      },
      body: openPage
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      height: double.infinity,
                      width: MediaQuery.of(context).size.height / 2,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 40),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                        image: aPF!.metadata.albumArt == null
                            ? null
                            : DecorationImage(
                                image: MemoryImage(aPF!.metadata.albumArt!),
                                fit: BoxFit.cover,
                              ),
                      ),
                      child: aPF!.metadata.albumArt == null
                          ? const Icon(
                              Icons.audiotrack_rounded,
                              color: Colors.white,
                              size: 200,
                            )
                          : null,
                    ),
                  ),
                ),
                Text(
                  aPF!.trackName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(aPF!.albumName),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Slider(
                    min: 0,
                    max: aPF!.duration.inSeconds.toDouble(),
                    value: aPF!.position.inSeconds.toDouble(),
                    onChanged: (value) async {
                      final position = Duration(seconds: value.toInt());
                      await aPF!.audioPlayer.seek(position);

                      setState(() => aPF!.isPlayer = true);
                      await aPF!.audioPlayer.resume();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(timeVideo(aPF!.position)),
                      Text(timeVideo(aPF!.duration))
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 35,
                  child: IconButton(
                    onPressed: () async {
                      if (aPF!.isPlayer) {
                        await aPF!.audioPlayer.pause();
                      } else {
                        await aPF!.audioPlayer
                            .play(DeviceFileSource(widget.file.path));
                      }
                      setState(() => aPF!.isPlayer = !aPF!.isPlayer);
                    },
                    iconSize: 50,
                    icon: Icon(
                      aPF!.isPlayer
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
