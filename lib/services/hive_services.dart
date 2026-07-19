import 'package:hive/hive.dart';

class HiveService {
  final Box box = Hive.box('savedFiles');

  void saveFile(String name, String path) {
    box.put(name, path);
  }

  Map<dynamic, dynamic> getFiles() {
    return box.toMap();
  }

  void deleteFile(String key) {
    box.delete(key);
  }
}