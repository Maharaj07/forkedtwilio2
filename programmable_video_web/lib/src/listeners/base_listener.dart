import 'package:programmable_video_web/src/programmable_video_web.dart';

class BaseListener {
  // Should be overrided by all subclasses
  void addListeners() {
    throw UnimplementedError('addListeners has not been implemented');
  }

  void debug(String msg) {
    ProgrammableVideoPlugin.debug('Listener Event: $msg');
  }

  // Helper for debug statements
  String capitalize(String string) {
    if (string.isEmpty) {
      return string;
    }
    return string[0].toUpperCase() + string.substring(1);
  }
}
