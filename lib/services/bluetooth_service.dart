import 'dart:async';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import '../models/bluetooth_device_model.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  StreamSubscription<List<fbp.ScanResult>>? _scanSubscription;
  final StreamController<List<BluetoothDeviceModel>> _devicesController =
      StreamController<List<BluetoothDeviceModel>>.broadcast();

  Stream<List<BluetoothDeviceModel>> get devicesStream =>
      _devicesController.stream;

  Future<bool> checkBluetoothSupport() async {
    if (await fbp.FlutterBluePlus.isSupported == false) {
      return false;
    }
    return true;
  }

  Future<bool> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final adapterState = await fbp.FlutterBluePlus.adapterState.first;

        if (adapterState != fbp.BluetoothAdapterState.on) {
          return false;
        }
        return true;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isBluetoothEnabled() async {
    return await fbp.FlutterBluePlus.adapterState.first ==
        fbp.BluetoothAdapterState.on;
  }

  Future<void> startScan({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      await stopScan();

      _devicesController.add([]);

      final Set<String> deviceIds = <String>{};
      final List<BluetoothDeviceModel> devices = [];

      _scanSubscription = fbp.FlutterBluePlus.scanResults.listen(
        (results) {

          for (fbp.ScanResult result in results) {
            final deviceModel = BluetoothDeviceModel.fromScanResult(result);

            if (!deviceIds.contains(deviceModel.id)) {
              deviceIds.add(deviceModel.id);
              devices.add(deviceModel);
              _devicesController.add(List.from(devices));
            }
          }
        },
        onError: (e) {
        },
      );


      await fbp.FlutterBluePlus.adapterState
          .where((state) => state == fbp.BluetoothAdapterState.on)
          .first;

      await fbp.FlutterBluePlus.startScan(
        timeout: timeout,
        androidUsesFineLocation: true,
        androidScanMode: fbp.AndroidScanMode.lowLatency,
      );

    } catch (e) {
      rethrow;
    }
  }

  Future<void> stopScan() async {
    await fbp.FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  Stream<fbp.BluetoothAdapterState> get adapterStateStream =>
      fbp.FlutterBluePlus.adapterState;

  void dispose() {
    _scanSubscription?.cancel();
    _devicesController.close();
  }
}
