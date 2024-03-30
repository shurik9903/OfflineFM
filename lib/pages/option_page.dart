import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline_fm/data/option_data.dart';
import 'package:flutter_offline_fm/notifier/option_notifier.dart';
import 'package:flutter_offline_fm/notifier/radio_notifier.dart';
import 'package:flutter_offline_fm/services/music_client.dart';
import 'package:flutter_offline_fm/widgets/dialogs/alert_dialog.dart';
import 'package:flutter_offline_fm/widgets/dialogs/error_dialog.dart';
import 'package:flutter_offline_fm/widgets/option.dart';
import 'package:flutter_offline_fm/widgets/option_input_field.dart';
import 'package:provider/provider.dart';

class OptionPage extends StatefulWidget {
  const OptionPage({super.key});

  @override
  State<OptionPage> createState() => _OptionPageState();
}

class _OptionPageState extends State<OptionPage> {
  TextEditingController timeToSave = TextEditingController(text: '1');
  String? pathTosave;

  @override
  void initState() {
    timeToSave.text = context.read<OptionNotifier>().optionData.saveDays ?? '1';
    pathTosave = context.read<OptionNotifier>().optionData.pathToSave;
    super.initState();
  }

  changePathToSave() async {
    String? selectedDirectory = await FilePicker.platform
        .getDirectoryPath(initialDirectory: pathTosave);

    if (selectedDirectory != null) {
      setState(() {
        pathTosave = selectedDirectory;
      });
    }
  }

  deleteRecords() async {
    bool result = await showAlertDialog(
        context, 'Хотите удалить все записи радио?', 'Отмена', 'Удалить');

    if (!result) return;

    if (!mounted) return;

    String pathToSave =
        context.read<OptionNotifier>().optionData.pathToSave ?? '';

    context.read<RadioNotifier>().radios.forEach((key, value) {
      try {
        MusicClientSingleton().deleteRecord(key, pathToSave);
      } catch (e) {
        showErrorDialog(context, 'Ошибка удаления записи', e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            OptionData option =
                OptionData(saveDays: timeToSave.text, pathToSave: pathTosave);

            context.read<OptionNotifier>().optionData = option;

            Navigator.pop(context);
          },
        ),
        title: const Text('Настройки'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Option(
              title: 'Таймер',
              options: [
                OptionInputField(
                  controller: timeToSave,
                  text: 'Срок хранения записей: ',
                )
              ],
            ),
            Option(
              title: 'Хранилище',
              options: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    elevation: 0,
                  ),
                  onPressed: changePathToSave,
                  child: const Text(
                    "Место хранения записей",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    elevation: 0,
                  ),
                  onPressed: deleteRecords,
                  child: const Text(
                    "Удалить все записи",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
