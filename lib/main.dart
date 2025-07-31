import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/bluetooth_bloc.dart';
import 'bloc/bluetooth_event.dart';
import 'screens/bluetooth_scan_screen.dart';
import 'services/bluetooth_service.dart' as bs;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) =>
            BluetoothBloc(bluetoothService: bs.BluetoothService())
              ..add(const BluetoothInitialize()),
        child: const BluetoothScanScreen(),
      ),
    );
  }
}
