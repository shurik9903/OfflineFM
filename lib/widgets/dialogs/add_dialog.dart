import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline_fm/data/radio_data.dart';
import 'package:flutter_offline_fm/notifier/radio_notifier.dart';
import 'package:flutter_offline_fm/modules/page_open.dart';
import 'package:provider/provider.dart';

class AddDialog extends StatefulWidget {
  const AddDialog({super.key, this.info});

  final InfoRadioData? info;

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Uint8List? _image;

  bool _isAcceptButtonDisabled = true;

  @override
  void initState() {
    _urlController.text = widget.info?.url ?? '';
    _nameController.text = widget.info?.name ?? '';

    _image = widget.info?.image;

    _fieldFill();

    super.initState();
  }

  void _fieldFill() {
    setState(() {
      _isAcceptButtonDisabled =
          !(_urlController.text.isNotEmpty && _nameController.text.isNotEmpty);
    });
  }

  String? validateName(String? value) {
    if (value == null) return 'Введите имя радио!';

    if (widget.info != null) return null;

    bool contain = context.read<RadioNotifier>().radios.values.every(
        (element) => element.info.name.toLowerCase() != value.toLowerCase());

    if (contain) return null;

    return 'Радио с данным именем уже имеется в вашем списке!';
  }

  String? validateUrl(String? value) {
    if (value == null) return 'Введите url радио!';

    if (widget.info != null) return null;

    bool contain = context.read<RadioNotifier>().radios.values.every(
        (element) => element.info.url.toLowerCase() != value.toLowerCase());

    if (contain) return null;

    return 'Радио с данным url уже имеется в вашем списке!';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      TextFormField(
                        onChanged: (value) => _fieldFill(),
                        controller: _urlController,
                        validator: (value) => validateUrl(value),
                        decoration: const InputDecoration(
                          icon: Icon(Icons.public),
                          errorMaxLines: 2,
                          labelText: 'URL адресс',
                        ),
                        maxLines: 1,
                      ),
                      TextFormField(
                        onChanged: (value) => _fieldFill(),
                        controller: _nameController,
                        validator: (value) => validateName(value),
                        decoration: const InputDecoration(
                            icon: Icon(Icons.text_format),
                            labelText: 'Имя радио',
                            errorMaxLines: 2),
                        maxLines: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            elevation: 0,
                          ),
                          onPressed: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.image,
                            );

                            setState(() {
                              _image = result?.files.first.bytes;
                            });
                          },
                          child: const Text(
                            "Выбрать изображение",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      if (_image != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Image(image: MemoryImage(_image!)),
                        )
                    ],
                  ),
                ),
                Container(
                  color: Colors.grey,
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isAcceptButtonDisabled
                              ? Colors.grey.shade700
                              : Colors.blue,
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (_isAcceptButtonDisabled) return;
                          if (!_formKey.currentState!.validate()) return;
                          Navigator.pop(
                              context,
                              InfoRadioData(
                                name: _nameController.text,
                                url: _urlController.text,
                                image: _image,
                              ));
                        },
                        child: const Text(
                          "Добавить",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(context, null);
                        },
                        child: const Text(
                          "Отмена",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<InfoRadioData?> showAddDialog(BuildContext context,
    {InfoRadioData? info}) async {
  return await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) {
      return dialogOpen(context, AddDialog(info: info));
      // return;
    },
  );
}
