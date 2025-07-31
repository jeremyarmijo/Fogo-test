import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import '../models/bluetooth_device_model.dart';

abstract class BluetoothState extends Equatable {
  const BluetoothState();

  @override
  List<Object?> get props => [];
}

class BluetoothInitial extends BluetoothState {
  const BluetoothInitial();
}

class BluetoothLoading extends BluetoothState {
  const BluetoothLoading();
}

class BluetoothReady extends BluetoothState {
  final List<BluetoothDeviceModel> devices;
  final bool isScanning;
  final fbp.BluetoothAdapterState adapterState;

  const BluetoothReady({
    this.devices = const [],
    this.isScanning = false,
    this.adapterState = fbp.BluetoothAdapterState.unknown,
  });

  BluetoothReady copyWith({
    List<BluetoothDeviceModel>? devices,
    bool? isScanning,
    fbp.BluetoothAdapterState? adapterState,
  }) {
    return BluetoothReady(
      devices: devices ?? this.devices,
      isScanning: isScanning ?? this.isScanning,
      adapterState: adapterState ?? this.adapterState,
    );
  }

  @override
  List<Object?> get props => [devices, isScanning, adapterState];
}

class BluetoothError extends BluetoothState {
  final String message;

  const BluetoothError(this.message);

  @override
  List<Object?> get props => [message];
}

class BluetoothPermissionDenied extends BluetoothState {
  const BluetoothPermissionDenied();
}

class BluetoothNotSupported extends BluetoothState {
  const BluetoothNotSupported();
}

class BluetoothDisabled extends BluetoothState {
  const BluetoothDisabled();
}
