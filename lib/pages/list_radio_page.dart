import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_offline_fm/data/radio_data.dart';
import 'package:flutter_offline_fm/notifier/radio_notifier.dart';
import 'package:flutter_offline_fm/services/music_client.dart';

import 'package:provider/provider.dart';

class ListRadioPage extends StatefulWidget {
  const ListRadioPage({super.key});

  @override
  State<ListRadioPage> createState() => _ListRadioPageState();
}

class _ListRadioPageState extends State<ListRadioPage> {
  final TextEditingController _find = TextEditingController();
  List<InfoRadioData> _infoRadio = [];

  @override
  void initState() {
    () async {
      List<dynamic> listRadio =
          jsonDecode(await rootBundle.loadString('lib/data/stream_list.json'))
              as List<dynamic>;
      setState(() {
        _infoRadio = listRadio
            .map((radio) =>
                InfoRadioData(url: radio['url'], name: radio['name']))
            .toList();
      });
    }();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<InfoRadioData> filterRadio = _find.text.isEmpty
        ? _infoRadio
        : _infoRadio
            .where(
              (element) =>
                  element.name.toLowerCase().contains(_find.text.toLowerCase()),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: Column(
        children: [
          TextFormField(
            onChanged: (value) => setState(() {}),
            controller: _find,
            decoration: const InputDecoration(
              icon: Icon(Icons.filter_alt_rounded),
              labelText: 'Имя радио',
            ),
            maxLines: 1,
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: (context, index) {
                  bool contain = !context
                      .read<RadioNotifier>()
                      .radios
                      .values
                      .every((element) =>
                          element.info.name.toLowerCase() !=
                              filterRadio[index].name.toLowerCase() ||
                          element.info.url.toLowerCase() !=
                              filterRadio[index].url.toLowerCase());

                  return GestureDetector(
                    onTap: () {
                      if (contain) return;
                      MusicClientSingleton().addRadio(filterRadio[index]);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      color: contain ? Colors.grey : Colors.white,
                      child: Text(
                        filterRadio[index].name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(
                      height: 20,
                    ),
                itemCount: filterRadio.length),
          )
        ],
      ),
    );
  }
}
