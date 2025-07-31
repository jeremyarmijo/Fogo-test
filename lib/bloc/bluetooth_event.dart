import 'package:equatable/equatable.dart';

abstract class BluetoothEvent extends Equatable {
  const BluetoothEvent();

  @override
  List<Object?> get props => [];
}

class BluetoothInitialize extends BluetoothEvent {
  const BluetoothInitialize();
}

class BluetoothStartScan extends BluetoothEvent {
  const BluetoothStartScan();
}

class BluetoothStopScan extends BluetoothEvent {
  const BluetoothStopScan();
}

class BluetoothDevicesUpdated extends BluetoothEvent {
  final List<dynamic> devices;

  const BluetoothDevicesUpdated(this.devices);

  @override
  List<Object?> get props => [devices];
}

class BluetoothAdapterStateChanged extends BluetoothEvent {
  final dynamic adapterState;

  const BluetoothAdapterStateChanged(this.adapterState);

  @override
  List<Object?> get props => [adapterState];
}
