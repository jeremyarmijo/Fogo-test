import 'package:flutter/material.dart';
import '../models/bluetooth_device_model.dart';

class BluetoothDeviceItem extends StatelessWidget {
  final BluetoothDeviceModel device;
  final VoidCallback? onTap;

  const BluetoothDeviceItem({
    super.key,
    required this.device,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.bluetooth,
          color: _getRssiColor(device.rssi),
        ),
        title: Text(
          device.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${device.id}'),
            Text('RSSI: ${device.rssi} dBm'),
          ],
        ),
        trailing: Icon(
          _getRssiIcon(device.rssi),
          color: _getRssiColor(device.rssi),
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getRssiColor(int rssi) {
    if (rssi >= -50) {
      return Colors.green;
    } else if (rssi >= -70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  IconData _getRssiIcon(int rssi) {
    if (rssi >= -50) {
      return Icons.signal_cellular_4_bar;
    } else if (rssi >= -70) {
      return Icons.signal_cellular_alt_2_bar;
    } else {
      return Icons.signal_cellular_alt_1_bar;
    }
  }
}
