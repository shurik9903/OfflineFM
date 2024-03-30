import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_offline_fm/data/radio_data.dart';
import 'package:flutter_offline_fm/notifier/option_notifier.dart';
import 'package:flutter_offline_fm/services/music_player.dart';
import 'package:flutter_offline_fm/notifier/radio_notifier.dart';
import 'package:flutter_offline_fm/services/music_client.dart';
import 'package:flutter_offline_fm/widgets/dialogs/add_dialog.dart';
import 'package:flutter_offline_fm/widgets/dialogs/alert_dialog.dart';
import 'package:flutter_offline_fm/widgets/dialogs/error_dialog.dart';
import 'package:flutter_offline_fm/widgets/glass_container.dart';
import 'package:flutter_offline_fm/widgets/marquee_text.dart';
import 'package:flutter_offline_fm/widgets/RadioPageWidgets/control_radio_container.dart';
import 'package:flutter_offline_fm/widgets/RadioPageWidgets/header_radio_container.dart';
import 'package:just_audio/just_audio.dart';

import 'package:provider/provider.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key, required this.index});

  final int index;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with TickerProviderStateMixin {
  late int index;

  String musicGroup = '';
  String musicName = '';

  Duration? duration;
  Duration? position;

  StreamSubscription<IcyMetadata?>? icyStream;
  StreamSubscription<Duration?>? durationStream;
  StreamSubscription<Duration?>? positionStream;

  @override
  void initState() {
    index = widget.index;

    if (context.read<RadioNotifier>().radios[index]!.info.playing) {
      subscribeStream();
    }
    super.initState();
  }

  void subscribeStream() {
    try {
      icyStream = MusicPlayerSingleton().audioHandler.icyStream.listen((event) {
        if (event == null) return;

        setState(() {
          List<String>? music = event.info?.title?.split(' - ');
          musicGroup = music?.first ?? ' ';
          musicName = music?.last ?? ' ';
        });
      });

      durationStream =
          MusicPlayerSingleton().audioHandler.durationStream.listen((event) {
        setState(() {
          duration = event;
        });
      });

      positionStream =
          MusicPlayerSingleton().audioHandler.positionStream.listen((event) {
        setState(() {
          position = event;
        });
      });
    } catch (e) {
      showErrorDialog(context, 'Ошибка воспроизведения радио!', e.toString());
    }
  }

  Future<void> subscribeCancel() async {
    await icyStream?.cancel();
    await durationStream?.cancel();
    await positionStream?.cancel();
  }

  @override
  void deactivate() {
    print('test1');
    subscribeCancel();
    super.deactivate();
  }

  @override
  void dispose() {
    print('test2');
    subscribeCancel();
    super.dispose();
  }

  deleteRadio() async {
    await MusicClientSingleton().deleteRadio(index);
    if (!mounted) return;
    if (context.read<RadioNotifier>().radios.isEmpty) {
      Navigator.pop(context);
    } else {
      nextRadio();
    }
  }

  changeRadio(List<int> list) {
    int value = list.first;

    if (value == index) {
      value = list.last;
    } else {
      list.every((element) {
        if (element == index) {
          return false;
        }
        value = element;
        return true;
      });
    }

    setState(() {
      index = value;
    });
  }

  prevRadio() {
    List<int> radio = context.read<RadioNotifier>().radios.keys.toList();
    changeRadio(radio);
  }

  nextRadio() {
    List<int> radio = context.read<RadioNotifier>().radios.keys.toList();
    changeRadio(radio.reversed.toList());
  }

  stop() {
    try {
      subscribeCancel();
      bool result = MusicClientSingleton().stopRadio(index);
      setState(() {
        musicGroup = '';
        musicName = '';
      });

      return result;
    } catch (e) {
      showErrorDialog(context, 'Не удалось остановить радио', e.toString());
    }
  }

  play() async {
    try {
      bool result = await MusicClientSingleton().playRadio(index);

      if (result) {
        await subscribeCancel();
        subscribeStream();
      }

      return result;
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, 'Не удалось запустить радио', e.toString());
    }
  }

  Future onChangedPosition(Duration position) async =>
      await MusicPlayerSingleton().audioHandler.seek(position);

  @override
  Widget build(BuildContext context) {
    RadioData? data = context.watch<RadioNotifier>().radios[index];
    return Scaffold(
        appBar: AppBar(
          title: SizedBox(
            width: double.infinity,
            height: 50,
            child: MarqueeText(
              text: data?.info.name ?? '',
              color: Colors.black,
            ),
          ),
          actions: [
            PopupMenuButton(
              offset: const Offset(0, 55),
              icon: const Icon(Icons.radio_button_checked_outlined),
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: () {
                    RecordData record = RecordData(
                        time: data.record.time, bytes: data.record.bytes);

                    record.isRecord = !data.record.isRecord;
                    String pathToSave =
                        context.read<OptionNotifier>().optionData.pathToSave ??
                            '';
                    MusicClientSingleton().setRecord(record, index, pathToSave);
                  },
                  child: data!.record.isRecord
                      ? const Text('Отключить запись')
                      : const Text('Включить запись'),
                ),
                if (data.record.time.inSeconds > 0 ||
                    data.record.bytes.butesSize > 0)
                  PopupMenuItem(
                    onTap: () {},
                    child: const Text('Воспроизвести запись'),
                  ),
                PopupMenuItem(
                  onTap: () {
                    String pathToSave =
                        context.read<OptionNotifier>().optionData.pathToSave ??
                            '';
                    try {
                      MusicClientSingleton().deleteRecord(index, pathToSave);
                    } catch (e) {
                      showErrorDialog(
                          context, 'Ошибка удаления записи', e.toString());
                    }
                  },
                  child: const Text('Удалить запись'),
                ),
              ],
            ),
            PopupMenuButton(
              offset: const Offset(0, 55),
              icon: const Icon(Icons.more_vert_rounded),
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: () async {
                    InfoRadioData? info = await showAddDialog(context,
                        info:
                            context.read<RadioNotifier>().radios[index]!.info);
                    if (info == null) return;

                    if (!context.mounted) return;
                    String pathToSave =
                        context.read<OptionNotifier>().optionData.pathToSave ??
                            '';
                    MusicClientSingleton().setInfo(info, index, pathToSave);
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(
                        width: 5,
                      ),
                      Text('Редактировать'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () async {
                    bool result = await showAlertDialog(
                      context,
                      'Вы уверены что хотите удалить данное радио вместе с записью?',
                      'Отмена',
                      'Удалить',
                    );

                    if (!result) return;
                    deleteRadio();
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(
                        width: 5,
                      ),
                      Text('Удалить радио'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: data == null
            ? Container()
            : Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('lib/images/radio_background.jpg'),
                      fit: BoxFit.cover),
                ),
                child: GlassContainer(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    HeaderRadioContainer(
                      image: data.info.image,
                      group: musicGroup,
                      name: musicGroup,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ControlRadioContainer(
                        isPlaying: context
                                .watch<RadioNotifier>()
                                .radios[index]
                                ?.info
                                .playing ??
                            false,
                        recordData: data.record,
                        nextRadio: nextRadio,
                        prevRadio: prevRadio,
                        play: play,
                        stop: stop,
                        onChangedPosition: onChangedPosition,
                        duration: duration,
                        position: position,
                      ),
                    ),
                  ],
                )),
              ));
  }
}
