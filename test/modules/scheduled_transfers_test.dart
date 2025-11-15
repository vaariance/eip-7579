import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:eip7579/eip7579.dart';
import 'package:variance_dart/variance_dart.dart';
import '../helpers/mocks.dart';

void main() {
  test('ScheduledTransfers getters sanity', () {
    final wallet = MockSmartWallet();
    final v = ScheduledTransfers(
      wallet,
      BigInt.from(60),
      BigInt.from(10),
      DateTime.utc(2025, 1, 1),
      Uint8List.fromList([0x01]),
    );

    expect(v.name, 'ScheduledTransfers');
    expect(v.type, ModuleType.executor);
    expect(v.version, '1.0.0');
  });

  test('Schedule value object holds fields', () {
    final s = Schedule(
      startDate: DateTime.utc(2025, 1, 1),
      repeatEvery: BigInt.from(3600),
      numberOfRepeats: BigInt.from(3),
    );
    expect(s.startDate.year, 2025);
    expect(s.repeatEvery, BigInt.from(3600));
    expect(s.numberOfRepeats, BigInt.from(3));
  });
}
