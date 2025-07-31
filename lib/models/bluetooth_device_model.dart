import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

class BluetoothDeviceModel {
  final String id;
  final String name;
  final int rssi;
  final fbp.BluetoothDevice device;

  BluetoothDeviceModel({
    required this.id,
    required this.name,
    required this.rssi,
    required this.device,
  });

  factory BluetoothDeviceModel.fromScanResult(fbp.ScanResult scanResult) {
    return BluetoothDeviceModel(
      id: scanResult.device.remoteId.toString(),
      name: scanResult.device.platformName.isNotEmpty 
          ? scanResult.device.platformName 
          : 'Unknown Device',
      rssi: scanResult.rssi,
      device: scanResult.device,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BluetoothDeviceModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BluetoothDeviceModel{id: $id, name: $name, rssi: $rssi}';
  }
}
