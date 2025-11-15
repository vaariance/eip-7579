import 'package:flutter_test/flutter_test.dart';
import 'package:eip7579/src/7579/extensions.dart';

void main() {
  test('BigInt.toBytes pads to requested length', () {
    final value = BigInt.from(0x1234);
    final bytes = value.toBytes(6);
    expect(bytes.length, 6);
    // Confirm padded left
    expect(bytes[4], 0x12);
    expect(bytes[5], 0x34);
  });
}
