import 'dart:typed_data';

String formatTime(Duration duration, {bool short = true}) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));

  return [if (duration.inHours > 0 || !short) hours, minutes, seconds]
      .join(':');
}

Duration stringToDuration(String time) {
  List<String> duration = time.split(':');
  return Duration(
      hours: int.parse(duration[0]),
      minutes: int.parse(duration[0]),
      seconds: int.parse(duration[0]));
}

class InfoRadioData {
  InfoRadioData(
      {required this.url,
      required this.name,
      this.image,
      this.playing = false});

  String url;
  String name;
  Uint8List? image;
  bool playing;

  factory InfoRadioData.fromJson(Map<String, dynamic> json) {
    return InfoRadioData(
        url: json['url'] as String,
        name: json['name'] as String,
        image: json['image'] != null
            ? Uint8List.fromList(json['image'].cast<int>().toList())
            : null);
  }

  Map<String, dynamic> toJson() => {'url': url, 'name': name, 'image': image};
}

class BytesSize {
  BytesSize(this.butesSize);

  int butesSize;

  double toKB() {
    return butesSize / 1000;
  }

  double toMB() {
    return toKB() / 1000;
  }

  double toGB() {
    return toMB() / 1000;
  }

  String getSize() {
    if (butesSize < 1000) return '$butesSize B';

    if (toKB() < 1000) return '${toKB().toStringAsFixed(2)} KB';

    if (toMB() < 1000) return '${toMB().toStringAsFixed(2)} MB';

    return '${toGB().toStringAsFixed(2)} KB';
  }

  static int toJson(BytesSize bytesSize) => bytesSize.butesSize;
}

class RecordData {
  RecordData({required this.time, required this.bytes});

  Duration time;
  BytesSize bytes;
  bool isRecord = false;

  factory RecordData.fromJson(Map<String, dynamic> json) {
    return RecordData(
        time: stringToDuration(json['time']), bytes: BytesSize(json['bytes']));
  }

  Map<String, dynamic> toJson() => {
        'time': formatTime(time, short: false),
        'bytes': bytes.butesSize,
      };
}

class RadioData {
  RadioData({required this.info, required this.record});

  InfoRadioData info;
  RecordData record;

  factory RadioData.fromJson(Map<String, dynamic> json) {
    return RadioData(
        info: InfoRadioData.fromJson(json['info']),
        record: RecordData.fromJson(json['record']));
  }

  Map<String, dynamic> toJson() => {
        'info': info,
        'record': record,
      };
}
