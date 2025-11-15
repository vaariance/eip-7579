import 'dart:typed_data' show Uint8List;

import 'package:eip7579/eip7579.dart' show Validator;
import 'package:web3_signers/web3_signers.dart';
import 'package:web3dart/web3dart.dart' show intToBytes;

extension BigIntExt on BigInt {
  Uint8List toBytes(int? bytes) {
    final value = intToBytes(this);
    return value.padToNBytes(bytes ?? value.length);
  }
}

extension DoubleExt on double {
  BigInt toBigInt() => BigInt.from(this);
  Uint8List toBytes(int? bytes) => toBigInt().toBytes(bytes);
}

extension ValidatorExt on List<Validator> {
  Uint8List get encoded => abi.encode(
    ["(bytes32,bytes)[]"],
    [
      [
        ...map(
          (e) => [
            e.validatorId.padToNBytes(12).concat(e.validatorAddress.value),
            e.data,
          ],
        ),
      ],
    ],
  );
}
