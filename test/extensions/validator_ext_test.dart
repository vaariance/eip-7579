import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:eip7579/eip7579.dart';
import 'package:eip7579/src/7579/extensions.dart';
import 'package:web3_signers/web3_signers.dart';

void main() {
  test('ValidatorExt.encoded produces ABI-compatible bytes', () {
    final id = Uint8List.fromList(List<int>.generate(12, (i) => i));
    final validators = <Validator>[
      (
        validatorAddress: Address.fromHex(
          '0x00000000000000000000000000000000000000AA',
        ),
        validatorId: id,
        data: Uint8List(0),
      ),
      (
        validatorAddress: Address.fromHex(
          '0x00000000000000000000000000000000000000BB',
        ),
        validatorId: id,
        data: Uint8List.fromList([1, 2, 3]),
      ),
    ];

    final encoded = validators.encoded;
    expect(encoded, isA<Uint8List>());
    expect(encoded.isNotEmpty, isTrue);
  });
}
