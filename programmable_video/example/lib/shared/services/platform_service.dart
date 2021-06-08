import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:uuid/uuid.dart';

class PlatformService {
  static Future<String> get deviceId async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor;
    } else if (Platform.isAndroid) {
      var androidInfo = await deviceInfo.androidInfo;
      return androidInfo.androidId;
    } else {
      // Platform is Web
      return Uuid().v1();
    }
  }
}
