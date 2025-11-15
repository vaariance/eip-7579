import 'package:flutter_test/flutter_test.dart';
import 'package:eip7579/src/7579/extensions.dart';

void main() {
  test('Double.toBigInt converts correctly', () {
    expect(42.0.toBigInt(), BigInt.from(42));
  });

  test('Double.toBytes outputs fixed-size Uint8List', () {
    final bytes = 42.0.toBytes(32);
    expect(bytes.length, 32);
  });
}