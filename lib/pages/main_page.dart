import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline_fm/data/option_data.dart';
import 'package:flutter_offline_fm/data/radio_data.dart';
import 'package:flutter_offline_fm/modules/record_info.dart';
import 'package:flutter_offline_fm/notifier/option_notifier.dart';
import 'package:flutter_offline_fm/notifier/radio_notifier.dart';
import 'package:flutter_offline_fm/pages/list_radio_page.dart';
import 'package:flutter_offline_fm/modules/page_open.dart';
import 'package:flutter_offline_fm/services/music_client.dart';
import 'package:flutter_offline_fm/services/music_player.dart';
import 'package:flutter_offline_fm/widgets/dialogs/add_dialog.dart';
import 'package:flutter_offline_fm/widgets/radio_container.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'option_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // final RadioNotifier _radio = RadioNotifier();

  final OptionNotifier _option = OptionNotifier();

  updateRecordState() {
    MusicClientSingleton().radios.forEach((key, value) async {
      RecordData record = await updateRecordInfo(
          '${_option.optionData.pathToSave}/OfflineFM/${value.info.name}');
      record.isRecord = value.record.isRecord;
      MusicClientSingleton()
          .setRecord(record, key, _option.optionData.pathToSave ?? '');
    });
  }

  @override
  void initState() {
    (() async {
      SharedPreferences? prefs = await SharedPreferences.getInstance();
      String? radioData = prefs.getString('radio');
      String? optionData = prefs.getString('option');

      if (optionData != null) {
        _option.optionData = OptionData.fromJson(jsonDecode(optionData));
      }

      List<RadioData> listRadio = radioData != null
          ? List.from(jsonDecode(radioData))
              .map((json) => RadioData.fromJson(json))
              .toList()
          : [];

      MusicClientSingleton().addAll(listRadio);
      // MusicPlayerSingleton().audioHandler.playPlaylist(listRadio
      //     .map((e) => MediaItem(id: e.info.url, title: 'title'))
      //     .toList());

      updateRecordState();
      Timer.periodic(
          const Duration(minutes: 1), (timer) => updateRecordState());
    })();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MusicClientSingleton().radioNotifier,
        ),
        ChangeNotifierProvider(
          create: (context) => _option,
        ),
      ],
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (context) {
                return const Icon(Icons.radio);
              },
            ),
            title: const Text('OfflineFM'),
            actions: [
              PopupMenuButton(
                offset: const Offset(0, 55),
                icon: const Icon(Icons.add_circle_outline),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        InfoRadioData? info = await showAddDialog(context);
                        if (info != null && mounted) {
                          MusicClientSingleton().addRadio(info);
                        }
                      });
                    },
                    child: const Text('Добавить свое радио'),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        await pageOpen(context, const ListRadioPage());
                      });
                    },
                    child: const Text('Добавить радио из списка'),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => pageOpen(context, const OptionPage()),
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          body: Center(
            child: Container(
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('lib/images/radio_background.jpg'),
                    fit: BoxFit.cover),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: context.select(
                            (RadioNotifier notifier) => notifier.radios.length),
                        itemBuilder: (context, index) => Builder(
                          builder: (context) {
                            int currentIndex = context
                                .select(
                                    (RadioNotifier notifier) => notifier.radios)
                                .keys
                                .toList()[index];
                            return RadioContainer(index: currentIndex);
                          },
                        ),
                        separatorBuilder: (context, index) => const SizedBox(
                          width: 10,
                        ),
                      ),
                    ),
                  ),
                  context.select(
                    (RadioNotifier notifier) => notifier.current != null
                        ? Container(
                            color: Colors.black.withOpacity(0.8),
                            child: RadioContainer(
                              index: notifier.current!,
                            ),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
