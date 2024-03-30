import 'dart:io';

Map<String, dynamic> musicDirStatSync(String dirPath) {
  List<File> files = [];
  int totalSize = 0;

  var dir = Directory(dirPath);
  try {
    if (dir.existsSync()) {
      dir
          .listSync(recursive: true, followLinks: false)
          .forEach((FileSystemEntity entity) {
        if (entity is File) {
          files.add(entity);
          totalSize += entity.lengthSync();
        }
      });
    }
  } catch (e) {
    throw Exception(e.toString());
  }

  return {'files': files, 'size': totalSize};
}
