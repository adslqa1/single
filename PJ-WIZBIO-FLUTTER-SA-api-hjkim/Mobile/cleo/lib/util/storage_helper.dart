import 'package:localstorage/localstorage.dart';

class StorageHelper {
  late String storageKey;
  late LocalStorage storage;

  Future init(String key) async {
    storageKey = key;
    storage = LocalStorage(storageKey);
  }

  Future getValue(String key, {String? valueKey}) async {
    if (await storage.ready) {
      dynamic value = storage.getItem(key);

      if (valueKey != null) {
        return value[valueKey];
      }
      return value;
    } else {
      return null;
    }
  }

  Future setValue(String key, dynamic value) async {
    await storage.setItem(key, value);
  }
}
