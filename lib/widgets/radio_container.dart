import 'package:flutter/material.dart';

import 'package:flutter_offline_fm/data/radio_data.dart';
import 'package:flutter_offline_fm/notifier/option_notifier.dart';
import 'package:flutter_offline_fm/notifier/radio_notifier.dart';
import 'package:flutter_offline_fm/pages/player_page.dart';
import 'package:flutter_offline_fm/services/music_client.dart';
import 'package:flutter_offline_fm/modules/page_open.dart';
import 'package:flutter_offline_fm/widgets/RadioPageWidgets/player_radio_container.dart';
import 'package:flutter_offline_fm/widgets/dialogs/add_dialog.dart';
import 'package:flutter_offline_fm/widgets/dialogs/error_dialog.dart';
import 'package:flutter_offline_fm/widgets/glass_container.dart';
import 'package:flutter_offline_fm/widgets/marquee_text.dart';
import 'package:provider/provider.dart';

class RadioContainer extends StatefulWidget {
  const RadioContainer({super.key, required this.index});

  final int index;

  @override
  State<RadioContainer> createState() => _RadioContainerState();
}

class _RadioContainerState extends State<RadioContainer> {
  late bool isPlaying;

  @override
  void initState() {
    isPlaying =
        context.read<RadioNotifier>().radios[widget.index]!.info.playing;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    RadioData data = context.watch<RadioNotifier>().radios[widget.index]!;
    isPlaying = data.info.playing;

    return GestureDetector(
      onTap: () => pageOpen(
          context,
          PlayerPage(
            index: widget.index,
          )),
      child: Container(
        padding: const EdgeInsets.all(5),
        child: GlassContainer(
          color: data.record.isRecord ? Colors.red : Colors.white,
          width: double.infinity,
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.all(5),
                  width: 45,
                  height: 45,
                  child: data.info.image == null
                      ? Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          child: const FittedBox(
                            child: Icon(
                              Icons.radio,
                              color: Colors.black,
                            ),
                          ),
                        )
                      : Image(
                          image: MemoryImage(data.info.image!),
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: MarqueeText(text: data.info.name),
                        ),
                        Row(
                          children: [
                            Text(
                              formatTime(data.record.time),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              ' | ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              data.record.bytes.getSize(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: PlayButton(
                    color: Colors.white70,
                    isPlaying: isPlaying,
                    toPlay: () async {
                      try {
                        return await MusicClientSingleton()
                            .playRadio(widget.index);
                      } catch (e) {
                        showErrorDialog(context, 'Не удалось запустить радио',
                            e.toString());
                      }
                    },
                    toStop: () async {
                      try {
                        return MusicClientSingleton().stopRadio(widget.index);
                      } catch (e) {
                        showErrorDialog(context, 'Не удалось остановить радио',
                            e.toString());
                      }
                    },
                  ),
                ),
                PopupMenuButton(
                  padding: const EdgeInsets.all(0),
                  offset: const Offset(5, 45),
                  color: Colors.white70,
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: Colors.white70,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () {
                        RecordData record = RecordData(
                            time: data.record.time, bytes: data.record.bytes);

                        record.isRecord = !data.record.isRecord;
                        String pathToSave = context
                                .read<OptionNotifier>()
                                .optionData
                                .pathToSave ??
                            '';
                        MusicClientSingleton()
                            .setRecord(record, widget.index, pathToSave);
                      },
                      height: 35,
                      mouseCursor: SystemMouseCursors.click,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.radio_button_checked_rounded,
                            color: data.record.isRecord ? Colors.red : null,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(data.record.isRecord
                              ? 'Отключить запись'
                              : 'Включить запись')
                        ],
                      ),
                    ),
                    if (data.record.time.inSeconds > 0 ||
                        data.record.bytes.butesSize > 0) ...[
                      PopupMenuItem(
                        onTap: () {
                          String pathToSave = context
                                  .read<OptionNotifier>()
                                  .optionData
                                  .pathToSave ??
                              '';
                          MusicClientSingleton()
                              .playPlaylist(pathToSave, widget.index);
                        },
                        height: 35,
                        mouseCursor: SystemMouseCursors.click,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fiber_smart_record,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Воспроизвести запись')
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () {
                          String pathToSave = context
                                  .read<OptionNotifier>()
                                  .optionData
                                  .pathToSave ??
                              '';
                          MusicClientSingleton()
                              .deleteRecord(widget.index, pathToSave);
                        },
                        height: 35,
                        mouseCursor: SystemMouseCursors.click,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.do_not_disturb_on_total_silence_outlined,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Удалить запись')
                          ],
                        ),
                      ),
                    ],
                    PopupMenuItem(
                      onTap: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          InfoRadioData? info = await showAddDialog(context,
                              info: context
                                  .read<RadioNotifier>()
                                  .radios[widget.index]!
                                  .info);
                          if (info == null) return;

                          if (!mounted) return;

                          String pathToSave = context
                                  .read<OptionNotifier>()
                                  .optionData
                                  .pathToSave ??
                              '';
                          MusicClientSingleton()
                              .setInfo(info, widget.index, pathToSave);
                        });
                      },
                      height: 35,
                      mouseCursor: SystemMouseCursors.click,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text('Редактировать')
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () async => await MusicClientSingleton()
                          .deleteRadio(widget.index),
                      height: 35,
                      mouseCursor: SystemMouseCursors.click,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.delete),
                          SizedBox(
                            width: 5,
                          ),
                          Text('Удалить')
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
