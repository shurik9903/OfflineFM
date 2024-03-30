import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_offline_fm/data/radio_data.dart';

interface class IServiceState {
  void serviceStateUpdate(Map<int, RadioData> radios) async {}
}

class ServiceState implements IServiceState {
  @override
  void serviceStateUpdate(Map<int, RadioData> radios) async {
    FlutterBackgroundService service = FlutterBackgroundService();
    if (!radios.values.every((element) => !element.record.isRecord)) {
      if (!(await service.isRunning())) service.startService();
    } else {
      if (await service.isRunning()) service.invoke('stopService');
    }
  }
}
