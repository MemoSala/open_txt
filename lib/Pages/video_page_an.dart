import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../model/screen_tools.dart';
import '../widgets/scaffold_file.dart';

class VideoPageAN extends StatefulWidget {
  final File file;

  const VideoPageAN({super.key, required this.file});

  @override
  State<VideoPageAN> createState() => _VideoPageANState();
}

class _VideoPageANState extends State<VideoPageAN> with ScreenTools {
  late VideoPlayerController controller;
  bool isTape = true, isSmoil = true, isVolumeOn = true;

  void initStateFuture() {
    controller = VideoPlayerController.file(widget.file)
      ..addListener(() => setState(() {}))
      ..setLooping(false)
      ..setVolume(100)
      ..initialize().then((vol) {});
  }

  @override
  void initState() {
    super.initState();
    initStateFuture();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void ranVideo() {
    if (controller.value.isPlaying) {
      controller.pause();
      setState(() => isTape = true);
    } else {
      controller.play();
      setState(() => isTape = false);
    }
  }

  void voidIsTape() {
    if (isTape) {
      setState(() => isTape = false);
    } else {
      setState(() => isTape = true);
      Timer(const Duration(seconds: 3), () {
        if (controller.value.isPlaying) {
          setState(() => isTape = false);
        }
      });
    }
  }

  void rotateScreen() async => isSmoil
      ? await horizontalScreen()
          .then((value) => setState(() => isSmoil = false))
      : await verticalScreen().then((value) => setState(() => isSmoil = true));

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
          ? Stack(alignment: Alignment.bottomCenter, children: [
              Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, value, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Row(children: [
                          Expanded(
                            child: GestureDetector(
                              onDoubleTap: () => controller.seekTo(
                                value.position - const Duration(seconds: 10),
                              ),
                              onTap: voidIsTape,
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onDoubleTap: ranVideo,
                              onTap: voidIsTape,
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onDoubleTap: () => controller.seekTo(
                                value.position + const Duration(seconds: 10),
                              ),
                              onTap: voidIsTape,
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                        ]),
                      ),
                      if (isTape)
                        Row(children: [
                          Expanded(
                            child: Container(
                              height: 5,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 2.5),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: VideoProgressIndicator(
                                  controller,
                                  allowScrubbing: true,
                                  padding: EdgeInsets.zero,
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
                      if (isTape)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() => isVolumeOn = !isVolumeOn);
                                controller.setVolume(isVolumeOn ? 100 : 0);
                              },
                              iconSize: 40,
                              color: Colors.white,
                              icon: Icon(
                                isVolumeOn
                                    ? Icons.volume_up_rounded
                                    : Icons.volume_off_rounded,
                              ),
                            ),
                            IconButton(
                              onPressed: () => controller.seekTo(
                                value.position - const Duration(seconds: 10),
                              ),
                              iconSize: 40,
                              color: Colors.white,
                              icon: const Icon(Icons.fast_rewind_rounded),
                            ),
                            IconButton(
                              onPressed: ranVideo,
                              iconSize: 40,
                              color: Colors.white,
                              icon: Icon(
                                controller.value.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                            ),
                            IconButton(
                              onPressed: () => controller.seekTo(
                                value.position + const Duration(seconds: 10),
                              ),
                              iconSize: 40,
                              color: Colors.white,
                              icon: const Icon(Icons.fast_forward_rounded),
                            ),
                            IconButton(
                              onPressed: rotateScreen,
                              iconSize: 40,
                              color: Colors.white,
                              icon: Icon(
                                isSmoil
                                    ? Icons.fullscreen_rounded
                                    : Icons.fullscreen_exit_rounded,
                              ),
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ])
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
