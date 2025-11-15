import 'package:flutter_test/flutter_test.dart';
import 'package:eip7579/eip7579.dart';
import 'package:variance_dart/variance_dart.dart';
import 'package:web3_signers/web3_signers.dart';
import '../helpers/mocks.dart';

void main() {
  test('OwnableValidator constructor asserts invalid threshold', () {
    final wallet = MockSmartWallet();
    final owners = [
      Address.fromHex('0x00000000000000000000000000000000000000A1'),
    ];
    expect(
      () => OwnableValidator(wallet, BigInt.zero, owners),
      throwsA(isA<AssertionError>()),
    );
  });

  test('OwnableValidator constructor asserts owners length < threshold', () {
    final wallet = MockSmartWallet();
    final owners = [
      Address.fromHex('0x00000000000000000000000000000000000000B1'),
    ];
    expect(
      () => OwnableValidator(wallet, BigInt.from(2), owners),
      throwsA(isA<AssertionError>()),
    );
  });

  test('OwnableValidator getters sanity', () {
    final wallet = MockSmartWallet();
    final owners = [
      Address.fromHex('0x00000000000000000000000000000000000000C1'),
      Address.fromHex('0x00000000000000000000000000000000000000C2'),
    ];
    final v = OwnableValidator(wallet, BigInt.from(2), owners);
    expect(v.name, 'OwnableValidator');
    expect(v.type, ModuleType.validator);
    expect(v.version, '1.0.0');
  });
}
