import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bluetooth_scanner/bloc/bluetooth_bloc.dart';
import 'package:bluetooth_scanner/bloc/bluetooth_event.dart';
import 'package:bluetooth_scanner/bloc/bluetooth_state.dart' as bts;
import 'package:bluetooth_scanner/services/bluetooth_service.dart' as bs;

// Mock class for BluetoothService
class MockBluetoothService extends Mock implements bs.BluetoothService {}

void main() {
  group('BluetoothBloc', () {
    late bs.BluetoothService mockBluetoothService;

    setUp(() {
      mockBluetoothService = MockBluetoothService();
    });

    test('initial state is BluetoothInitial', () {
      final bloc = BluetoothBloc(bluetoothService: mockBluetoothService);
      expect(bloc.state, equals(const bts.BluetoothInitial()));
      bloc.close();
    });

    group('BluetoothInitialize', () {
      blocTest<BluetoothBloc, bts.BluetoothState>(
        'emits [BluetoothLoading, BluetoothNotSupported] when Bluetooth is not supported',
        setUp: () {
          when(() => mockBluetoothService.checkBluetoothSupport())
              .thenAnswer((_) async => false);
        },
        build: () => BluetoothBloc(bluetoothService: mockBluetoothService),
        act: (bloc) => bloc.add(const BluetoothInitialize()),
        expect: () => [
          const bts.BluetoothLoading(),
          const bts.BluetoothNotSupported(),
        ],
        verify: (_) {
          verify(() => mockBluetoothService.checkBluetoothSupport()).called(1);
        },
      );

      blocTest<BluetoothBloc, bts.BluetoothState>(
        'emits [BluetoothLoading, BluetoothPermissionDenied] when permissions are denied',
        setUp: () {
          when(() => mockBluetoothService.checkBluetoothSupport())
              .thenAnswer((_) async => true);
          when(() => mockBluetoothService.requestPermissions())
              .thenAnswer((_) async => false);
        },
        build: () => BluetoothBloc(bluetoothService: mockBluetoothService),
        act: (bloc) => bloc.add(const BluetoothInitialize()),
        expect: () => [
          const bts.BluetoothLoading(),
          const bts.BluetoothPermissionDenied(),
        ],
        verify: (_) {
          verify(() => mockBluetoothService.checkBluetoothSupport()).called(1);
          verify(() => mockBluetoothService.requestPermissions()).called(1);
        },
      );
    });
  });
}
