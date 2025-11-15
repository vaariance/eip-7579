import 'package:flutter_test/flutter_test.dart';
import 'package:eip7579/eip7579.dart';
import 'package:variance_dart/variance_dart.dart';
import 'package:web3_signers/web3_signers.dart';
import '../helpers/mocks.dart';

void main() {
  test('OwnableExecutor getters sanity', () {
    final wallet = MockSmartWallet();
    final v = OwnableExecutor(
      wallet,
      Address.fromHex('0x00000000000000000000000000000000000000D1'),
    );
    expect(v.name, 'OwnableExecutor');
    expect(v.type, ModuleType.executor);
    expect(v.version, '1.0.0');
  });
}
