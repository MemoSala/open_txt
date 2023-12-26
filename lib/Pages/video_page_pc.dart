import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player_win/video_player_win.dart';

import '../model/screen_tools.dart';
import '../widgets/scaffold_file.dart';

class VideoPagePC extends StatefulWidget {
  final File file;

  const VideoPagePC({super.key, required this.file});

  @override
  State<VideoPagePC> createState() => _VideoPagePCState();
}

class _VideoPagePCState extends State<VideoPagePC> with ScreenTools {
  late WinVideoPlayerController controller;
  bool isTape = true, isVolumeOn = true;
  @override
  void initState() {
    super.initState();
    voidInitState();
  }

  void voidInitState() async {
    controller = WinVideoPlayerController.file(widget.file);
    await controller.initialize().then((value) async {
      if (controller.value.isInitialized) {
        setState(() {});
      } else {
        log("video file load failed");
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void ranVideo() {
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  String _timeVideo(Duration position) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");

    return [
      if (controller.value.duration.inHours > 0) twoDigits(position.inHours),
      twoDigits(position.inMinutes.remainder(60)),
      twoDigits(position.inSeconds.remainder(60)),
    ].join(":");
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldFile(
      appBarSpacing: true,
      isAppBar: isTape,
      file: widget.file,
      body: controller.value.isInitialized
          ? Stack(children: [
              WinVideoPlayer(
                controller,
                filterQuality: FilterQuality.high,
              ),
              ValueListenableBuilder(
                  valueListenable: controller,
                  builder: ((context, value, child) {
                    return Column(children: [
                      Expanded(
                        child: GestureDetector(onTap: () {
                          setState(() => isTape = !isTape);
                        }),
                      ),
                      Row(children: [
                        Expanded(
                          child: Container(
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 2.5),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white10,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(seconds: 1),
                              width: value.position.inSeconds *
                                  (MediaQuery.of(context).size.width - 61) /
                                  controller.value.duration.inSeconds,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          "${_timeVideo(value.position)}/${_timeVideo(controller.value.duration)}",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      ]),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        padding: const EdgeInsets.all(10),
                        height: isTape ? 97 : 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 87.5),
                            IconButton(
                              onPressed: () => controller.seekTo(
                                value.position -
                                    Duration(
                                        seconds: value.position.inSeconds <= 10
                                            ? value.position.inSeconds
                                            : 10),
                              ),
                              iconSize: 60,
                              color: Colors.white,
                              icon: const Icon(Icons.fast_rewind_rounded),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: ranVideo,
                              iconSize: 60,
                              color: Colors.white,
                              icon: Icon(
                                controller.value.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: () => controller.seekTo(
                                value.position +
                                    Duration(
                                        seconds: value.position.inSeconds -
                                                    value.position.inSeconds <=
                                                10
                                            ? 10
                                            : value.position.inSeconds -
                                                value.position.inSeconds -
                                                1),
                              ),
                              iconSize: 60,
                              color: Colors.white,
                              icon: const Icon(Icons.fast_forward_rounded),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: () {
                                setState(() => isVolumeOn = !isVolumeOn);
                                controller.setVolume(isVolumeOn ? 1 : 0);
                              },
                              iconSize: 60,
                              color: Colors.white,
                              icon: Icon(
                                isVolumeOn
                                    ? Icons.volume_up_rounded
                                    : Icons.volume_off_rounded,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }))
            ])
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
