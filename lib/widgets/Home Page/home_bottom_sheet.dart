import 'package:flutter/material.dart';
import 'package:open_txt/Pages/audio_page.dart';
import 'package:provider/provider.dart';

import '../../model/audio_play_file_provider.dart';

class HomeBottomSheet extends StatelessWidget {
  const HomeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayFileProvider>(builder: (context, value, child) {
      return GestureDetector(
        onTap: () async {
          await value.audioPlayFile!.listen!.cancel().then(
            (v) async {
              AudioPlayFile box = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AudioPage(
                    file: value.audioPlayFile!.file,
                    aPF: value.audioPlayFile,
                  ),
                ),
              );
              value.play(box);
              value.listen();
            },
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: value.isPlay ? 80 : 0,
          width: double.infinity,
          color: Colors.blue.withOpacity(0.3),
          child: value.isPlay
              ? Row(children: [
                  Container(
                    height: 60,
                    width: 60,
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(5),
                      image: value.audioPlayFile!.metadata.albumArt == null
                          ? null
                          : DecorationImage(
                              image: MemoryImage(
                                  value.audioPlayFile!.metadata.albumArt!),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: value.audioPlayFile!.metadata.albumArt == null
                        ? const Icon(
                            Icons.audiotrack_rounded,
                            color: Colors.white,
                            size: 40,
                          )
                        : null,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(children: [
                          CircleAvatar(
                            radius: 20,
                            child: IconButton(
                              onPressed: value.playAudio,
                              iconSize: 20,
                              icon: Icon(
                                value.audioPlayFile!.isPlayer
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  value.audioPlayFile!.trackName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  value.audioPlayFile!.albumName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 100,
                        height: 25,
                        child: SliderTheme(
                          data: const SliderThemeData(
                            minThumbSeparation: 0,
                            overlayColor: Colors.transparent,
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: 7.5,
                            ),
                          ),
                          child: Slider(
                            min: 0,
                            max: value.audioPlayFile!.duration.inSeconds
                                .toDouble(),
                            value: value.audioPlayFile!.position.inSeconds
                                .toDouble(),
                            onChanged: value.playAudioSlider,
                          ),
                        ),
                      ),
                    ],
                  )
                ])
              : null,
        ),
      );
    });
  }
}
