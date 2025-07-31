import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import '../bloc/bluetooth_bloc.dart';
import '../bloc/bluetooth_event.dart';
import '../bloc/bluetooth_state.dart' as bts;
import '../widgets/bluetooth_device_item.dart';

class BluetoothScanScreen extends StatefulWidget {
  const BluetoothScanScreen({super.key});

  @override
  State<BluetoothScanScreen> createState() => _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
  bool _showUnknownDevices = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bluetooth Devices',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showUnknownDevices = !_showUnknownDevices;
              });
            },
            icon: Icon(
              _showUnknownDevices ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey.shade700,
            ),
            tooltip: _showUnknownDevices
                ? 'Hide unknown devices'
                : 'Show unknown devices',
          ),
        ],
      ),
      body: BlocBuilder<BluetoothBloc, bts.BluetoothState>(
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
      floatingActionButton: BlocBuilder<BluetoothBloc, bts.BluetoothState>(
        builder: (context, state) {
          if (state is bts.BluetoothReady &&
              state.adapterState == fbp.BluetoothAdapterState.on) {
            return FloatingActionButton.extended(
              onPressed: () {
                if (state.isScanning) {
                  context.read<BluetoothBloc>().add(const BluetoothStopScan());
                } else {
                  context.read<BluetoothBloc>().add(const BluetoothStartScan());
                }
              },
              label: Text(
                state.isScanning ? 'Stop' : 'Search',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              icon: Icon(
                state.isScanning ? Icons.stop : Icons.bluetooth_searching,
              ),
              backgroundColor: state.isScanning ? Colors.red : Colors.blue,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, bts.BluetoothState state) {
    switch (state.runtimeType) {
      case const (bts.BluetoothInitial):
        return const Center(child: Text('Initializing Bluetooth...'));

      case const (bts.BluetoothLoading):
        return const Center(child: CircularProgressIndicator());

      case const (bts.BluetoothNotSupported):
        return _buildErrorMessage(
          'Bluetooth Not Supported',
          'This device does not support Bluetooth.',
          Icons.bluetooth_disabled,
        );

      case const (bts.BluetoothPermissionDenied):
        return _buildErrorMessage(
          'Permissions Required',
          'Bluetooth permissions are required to scan for devices.',
          Icons.security,
          actionText: 'Request Permissions',
          onActionPressed: () {
            context.read<BluetoothBloc>().add(const BluetoothInitialize());
          },
        );

      case const (bts.BluetoothDisabled):
        return _buildErrorMessage(
          'Bluetooth Disabled',
          'Please enable Bluetooth to scan for devices.',
          Icons.bluetooth_disabled,
          actionText: 'Check Again',
          onActionPressed: () {
            context.read<BluetoothBloc>().add(const BluetoothInitialize());
          },
        );

      case const (bts.BluetoothError):
        final errorState = state as bts.BluetoothError;
        return _buildErrorMessage(
          'Error',
          errorState.message,
          Icons.error,
          actionText: 'Retry',
          onActionPressed: () {
            context.read<BluetoothBloc>().add(const BluetoothInitialize());
          },
        );

      case const (bts.BluetoothReady):
        final readyState = state as bts.BluetoothReady;
        return _buildDevicesList(context, readyState);

      default:
        return const Center(child: Text('Unknown state'));
    }
  }

  Widget _buildErrorMessage(
    String title,
    String message,
    IconData icon, {
    String? actionText,
    VoidCallback? onActionPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onActionPressed,
                child: Text(actionText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDevicesList(BuildContext context, bts.BluetoothReady state) {
    return Column(
      children: [
        // Status indicator
        if (state.isScanning)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Searching...',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

        // Devices list
        Expanded(
          child: state.devices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bluetooth_searching,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        state.isScanning
                            ? 'Searching for devices...'
                            : 'No devices found',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (!state.isScanning) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Press the button to start searching',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                )
              : Builder(
                  builder: (context) {
                    final sortedDevices = List<dynamic>.from(state.devices)
                      ..sort((a, b) => b.rssi.compareTo(a.rssi));

                    final filteredDevices = _showUnknownDevices
                        ? sortedDevices
                        : sortedDevices
                              .where(
                                (device) =>
                                    device.name.isNotEmpty &&
                                    device.name != 'Unknown Device',
                              )
                              .toList();

                    return ListView.builder(
                      itemCount: filteredDevices.length,
                      itemBuilder: (context, index) {
                        final device = filteredDevices[index];
                        return BluetoothDeviceItem(
                          device: device,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Tapped on ${device.name}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
