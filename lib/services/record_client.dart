import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class RecordStream {
  StreamSubscription<List<int>>? responseSubscription;
  Client? client;
  String currentTitle = '';
  String url = '';

  stopRecord() async {
    await responseSubscription?.cancel();
    client?.close();
  }
}

class RecordClient {
  static final Map<String, RecordStream> _records = {};

  deleteRecord(String radioName) async {
    await stopRecord(radioName);
    _records.remove(radioName);
  }

  updateRecord(String radioName, String pathToSave,
      {String? newRadioName, String? newUrl}) async {
    if ((newRadioName == null && newUrl == null) ||
        (newRadioName?.isEmpty ?? true) ||
        (newUrl?.isEmpty ?? true)) return;

    if (newUrl == null && !_records.keys.contains(radioName)) return;

    await deleteRecord(radioName);

    return await startRecord(newRadioName ?? radioName,
        newUrl ?? _records[radioName]!.url, pathToSave);
  }

  writeMusicToFile(List<int> bytes, String pathToSave, String radioName) async {
    if (radioName.isEmpty || pathToSave.isEmpty) return;

    String title = _records[radioName]?.currentTitle ?? '';

    if (title.isEmpty) title = 'unknown';
    File file = File('$pathToSave/OfflineFM/$radioName/$title.mp3');
    if (!file.existsSync()) file.createSync(recursive: true);
    file.writeAsBytesSync(bytes, mode: FileMode.append, flush: true);
  }

  updateTitle(Uri uri, String radioName) async {
    final request = http.Request('GET', uri);
    request.headers["Icy-MetaData"] = "1";
    StreamedResponse response = await request.send();
    List<int> buffer = await response.stream.first;

    int metaint = int.parse(response.headers['icy-metaint'] ?? '0');
    if (buffer.length <= metaint) return;

    List<int> meta = buffer.skip(metaint).toList();

    if (meta.length < meta[0] * 16) return;

    String streamTitle =
        utf8.decode(meta.getRange(0, meta[0] * 16).skip(1).toList());

    if (streamTitle.isNotEmpty &&
        streamTitle.contains('StreamTitle=\'') &&
        streamTitle.contains('\';')) {
      String newTitle = streamTitle.substring(
          streamTitle.indexOf('StreamTitle=\'') + 'StreamTitle=\''.length,
          streamTitle.indexOf('\';'));

      _records[radioName]?.currentTitle = newTitle;
    }
  }

  startRecord(String radioName, String url, String pathToSave) async {
    print('record start $radioName');

    if (radioName.isEmpty || url.isEmpty || pathToSave.isEmpty) return false;

    _records[radioName] = RecordStream();
    _records[radioName]?.url = url;

    final Uri uri = Uri.parse(url);
    final Client client = http.Client();
    StreamSubscription<List<int>>? responseSubscription;

    try {
      final request = http.Request('GET', uri);
      final response = await client.send(request);

      responseSubscription = response.stream.listen((buffer) async {
        updateTitle(uri, radioName);
        writeMusicToFile(buffer, pathToSave, radioName);
      });

      _records[radioName]?.responseSubscription = responseSubscription;
      _records[radioName]?.client = client;
    } catch (e) {
      log('Record client error: ${e.toString()}');
      responseSubscription?.cancel();
      client.close();
      return false;
    }

    return true;
  }

  stopRecord(String radioName) async {
    print('record stop $radioName');
    await _records[radioName]?.stopRecord();
  }
}

class RecordClientSingleton extends RecordClient {
  static final RecordClientSingleton _radioPlayer =
      RecordClientSingleton._internal();

  factory RecordClientSingleton() {
    return _radioPlayer;
  }

  RecordClientSingleton._internal();
}
