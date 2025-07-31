import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import '../services/bluetooth_service.dart' as bs;
import '../models/bluetooth_device_model.dart';
import 'bluetooth_event.dart';
import 'bluetooth_state.dart' as bts;

class BluetoothBloc extends Bloc<BluetoothEvent, bts.BluetoothState> {
  final bs.BluetoothService _bluetoothService;
  StreamSubscription<List<BluetoothDeviceModel>>? _devicesSubscription;
  StreamSubscription<fbp.BluetoothAdapterState>? _adapterStateSubscription;
  Timer? _scanTimer;

  BluetoothBloc({bs.BluetoothService? bluetoothService})
    : _bluetoothService = bluetoothService ?? bs.BluetoothService(),
      super(const bts.BluetoothInitial()) {
    on<BluetoothInitialize>(_onInitialize);
    on<BluetoothStartScan>(_onStartScan);
    on<BluetoothStopScan>(_onStopScan);
    on<BluetoothDevicesUpdated>(_onDevicesUpdated);
    on<BluetoothAdapterStateChanged>(_onAdapterStateChanged);
  }

  Future<void> _onInitialize(
    BluetoothInitialize event,
    Emitter<bts.BluetoothState> emit,
  ) async {
    emit(const bts.BluetoothLoading());

    try {
      // Check if Bluetooth is supported
      final isSupported = await _bluetoothService.checkBluetoothSupport();
      if (!isSupported) {
        emit(const bts.BluetoothNotSupported());
        return;
      }

      // Request permissions
      final hasPermissions = await _bluetoothService.requestPermissions();
      if (!hasPermissions) {
        emit(const bts.BluetoothPermissionDenied());
        return;
      }

      // Check if Bluetooth is enabled
      final isEnabled = await _bluetoothService.isBluetoothEnabled();
      if (!isEnabled) {
        emit(const bts.BluetoothDisabled());
        return;
      }

      // Subscribe to device updates
      _devicesSubscription = _bluetoothService.devicesStream.listen(
        (devices) => add(BluetoothDevicesUpdated(devices)),
      );

      // Subscribe to adapter state changes
      _adapterStateSubscription = _bluetoothService.adapterStateStream.listen(
        (state) => add(BluetoothAdapterStateChanged(state)),
      );

      emit(const bts.BluetoothReady());
    } catch (e) {
      emit(bts.BluetoothError('Initialization failed: ${e.toString()}'));
    }
  }

  Future<void> _onStartScan(
    BluetoothStartScan event,
    Emitter<bts.BluetoothState> emit,
  ) async {
    if (state is bts.BluetoothReady) {
      final currentState = state as bts.BluetoothReady;

      if (currentState.adapterState != fbp.BluetoothAdapterState.on) {
        emit(const bts.BluetoothDisabled());
        return;
      }

      emit(currentState.copyWith(isScanning: true));

      try {
        await _bluetoothService.startScan();

        _scanTimer?.cancel();
        _scanTimer = Timer(const Duration(seconds: 30), () {
          add(const BluetoothStopScan());
        });
      } catch (e) {
        emit(bts.BluetoothError('Scan failed: ${e.toString()}'));
      }
    }
  }

  Future<void> _onStopScan(
    BluetoothStopScan event,
    Emitter<bts.BluetoothState> emit,
  ) async {
    if (state is bts.BluetoothReady) {
      final currentState = state as bts.BluetoothReady;
      emit(currentState.copyWith(isScanning: false));

      _scanTimer?.cancel();
      _scanTimer = null;

      try {
        await _bluetoothService.stopScan();
      } catch (e) {
        emit(bts.BluetoothError('Stop scan failed: ${e.toString()}'));
      }
    }
  }

  void _onDevicesUpdated(
    BluetoothDevicesUpdated event,
    Emitter<bts.BluetoothState> emit,
  ) {
    if (state is bts.BluetoothReady) {
      final currentState = state as bts.BluetoothReady;
      final devices = event.devices.cast<BluetoothDeviceModel>();
      emit(currentState.copyWith(devices: devices));
    }
  }

  void _onAdapterStateChanged(
    BluetoothAdapterStateChanged event,
    Emitter<bts.BluetoothState> emit,
  ) {
    if (state is bts.BluetoothReady) {
      final currentState = state as bts.BluetoothReady;
      final adapterState = event.adapterState as fbp.BluetoothAdapterState;

      if (adapterState != fbp.BluetoothAdapterState.on) {
        emit(
          currentState.copyWith(adapterState: adapterState, isScanning: false),
        );
      } else {
        emit(currentState.copyWith(adapterState: adapterState));
      }
    }
  }

  @override
  Future<void> close() {
    _devicesSubscription?.cancel();
    _adapterStateSubscription?.cancel();
    _scanTimer?.cancel();
    _bluetoothService.dispose();
    return super.close();
  }
}
