import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

class AudioPlayFileProvider extends ChangeNotifier {
  AudioPlayFile? audioPlayFile;

  void isPlayerGo() {
    audioPlayFile!.isPlayer = !audioPlayFile!.isPlayer;
    notifyListeners();
  }

  void isPlayerGoFalse() {
    audioPlayFile!.isPlayer = false;
    notifyListeners();
  }

  void isPlayerGoTrue() {
    audioPlayFile!.isPlayer = true;
    notifyListeners();
  }

  void playAudioSlider(double v) async {
    final position = Duration(seconds: v.toInt());
    await audioPlayFile!.audioPlayer.seek(position);
    await audioPlayFile!.audioPlayer.resume();
    isPlayerGoTrue();
  }

  void playAudio() async {
    if (audioPlayFile!.isPlayer) {
      await audioPlayFile!.audioPlayer.pause();
    } else {
      await audioPlayFile!.audioPlayer.play(
        DeviceFileSource(audioPlayFile!.file.path),
      );
    }
    isPlayerGo();
  }

  void play(AudioPlayFile newAudioPlayFile) {
    audioPlayFile = newAudioPlayFile;
    notifyListeners();
  }

  void close() async {
    await audioPlayFile!.listen!.cancel();
    await audioPlayFile!.audioPlayer.dispose();
    audioPlayFile = null;
    notifyListeners();
  }

  void listen() {
    audioPlayFile!.listen =
        audioPlayFile!.audioPlayer.onPositionChanged.listen((event) {
      audioPlayFile!.position = event;
      if (audioPlayFile!.position == audioPlayFile!.duration) {
        audioPlayFile!.isPlayer = false;
      }
      notifyListeners();
    });
    notifyListeners();
  }

  bool get isPlay => audioPlayFile != null;
}

class AudioPlayFile {
  final File file;
  AudioPlayer audioPlayer;
  bool isPlayer;
  Duration duration;
  Duration position;
  StreamSubscription<Duration>? listen;
  Metadata metadata;

  AudioPlayFile({
    required this.audioPlayer,
    required this.isPlayer,
    required this.duration,
    required this.position,
    this.listen,
    required this.file,
    required this.metadata,
  });

  String get trackName => (metadata.trackName ?? "No Name") == ""
      ? "No Name"
      : metadata.trackName ?? "No Name";
  String get albumName => (metadata.albumName ?? "No Album Name") == ""
      ? "No Album Name"
      : (metadata.albumName ?? "No Album Name");
}
